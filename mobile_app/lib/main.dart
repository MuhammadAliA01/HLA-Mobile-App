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





Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());

  // Don't block the Flutter UI from starting
  try {
    await NotificationService.initialize();

    final token = await NotificationService.getToken();

    print("FCM TOKEN: $token");
  } catch (e) {
    print("Notification initialization failed: $e");
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
      home: 
      Builder(builder: (context){
        return  Scaffold(
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
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), label: 'Calendar'),
            BottomNavigationBarItem(icon: Icon(Icons.access_time), label: 'Clock In/Out'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Log Health'),
          ],
        ),
        appBar: AppBar(
          title: Text(pageTitles[selectedIndex], style: TextStyle(color: Colors.white),),
          backgroundColor: const Color.fromARGB(255, 241, 182, 105),
          actions: [
            PopupMenuButton(
              onSelected: (value) async { if (value == 'Log Out'){
                 await storage.delete(key: 'token');
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Login()));
                
              }},
              icon: const Icon(Icons.account_circle, size: 35, color: Colors.black45,),
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(value: 'Log Out', child: Text('Log Out'))
              ],
            ),
          ],
        ),
      );
      })
      
    );
  }
}