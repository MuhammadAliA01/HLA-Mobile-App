import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'screens/calendar.dart';
import 'screens/clock_in_out.dart'; 
import 'screens/log_health.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int selectedIndex = 0; 

  
  final List<Widget> pages = const [
    Home(),
    Calendar(),
    ClockInOutScreen(),
    LogHealthScreen(classId: 1, className: "Class 1A",), 
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
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
          backgroundColor: const Color.fromARGB(255, 241, 182, 105),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.account_circle, size: 35, color: Colors.black45,),
            ),
          ],
        ),
      ),
    );
  }
}