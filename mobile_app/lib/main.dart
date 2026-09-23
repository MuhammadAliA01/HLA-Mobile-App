import 'package:flutter/material.dart';
import 'package:mobile_app/screens/account/login.dart';
import 'package:mobile_app/services/notification_service.dart';
import 'screens/homescreens/home.dart';
import 'screens/calendar.dart';
import 'screens/clock_in_out.dart';
import 'screens/log_health.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'screens/submit_leave_screen.dart';
import 'screens/payslip_history_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());

  try {
    await NotificationService.initialize();
    final token = await NotificationService.getToken();
    print("FCM TOKEN: $token");
  } catch (e) {
    print("Notification initialization failed: $e");
  }
}

class PayslipTab extends StatelessWidget {
  const PayslipTab({super.key});

  Future<int?> _getStaffId() async {
    final value = await const FlutterSecureStorage().read(key: 'staffId');
    return int.tryParse(value ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payslip History', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 241, 182, 105),
      ),
      body: FutureBuilder<int?>(
        future: _getStaffId(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final staffId = snapshot.data;

          if (staffId == null) {
            return const Center(
              child: Text('Staff ID not found. Please log out and log in again.'),
            );
          }

          return PayslipHistoryScreen(staffId: staffId);
        },
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final storage = const FlutterSecureStorage();
  int selectedIndex = 0;

  final List<Widget> pages = const [
    Home(),
    StaffSchedulePage(),
    ClockInOutScreen(),
    LogHealthScreen(classId: 1, className: "Class 1A"),
  ];

  final List<String> pageTitles = [
    'Home',
    'Calendar',
    'Clock In/Out',
    'Log Health',
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                pageTitles[selectedIndex],
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: const Color.fromARGB(255, 241, 182, 105),
              actions: [
                PopupMenuButton(
                  onSelected: (value) async {
                    if (value == 'Log Out') {
                      await storage.delete(key: 'token');
                      await storage.delete(key: 'staffId');
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const Login()),
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.account_circle,
                    size: 35,
                    color: Colors.black45,
                  ),
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem(
                      value: 'Log Out',
                      child: Text('Log Out'),
                    ),
                  ],
                ),
              ],
            ),
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const DrawerHeader(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 241, 182, 105),
                    ),
                    child: Text(
                      'Menu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.receipt_long),
                    title: const Text('Payslip History'),
                    onTap: () {
                      Navigator.pop(context); // Close the drawer
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PayslipTab(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            body: pages[selectedIndex],
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Colors.deepOrange,
              unselectedItemColor: Colors.black,
              currentIndex: selectedIndex,
              onTap: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_month_outlined),
                  label: 'Calendar',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.access_time),
                  label: 'Clock In/Out',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite),
                  label: 'Log Health',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}