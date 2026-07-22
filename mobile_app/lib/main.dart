import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'screens/calendar.dart';


void main(){

  runApp(MyApp());


}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override

  int SelectedIndex = 0;
  final List<Widget> pages = const [
    Home(),
    Calendar(),
  ];

  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: pages[SelectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black,
        currentIndex: SelectedIndex,
        onTap: (index) {
          setState(() {
            SelectedIndex = index;
          });
        } ,items: [BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'), BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), label: 'Calendar'), BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts')]
      ),
      appBar: AppBar(backgroundColor: Colors.blue, actions: [IconButton(onPressed: () {}, icon: Icon(Icons.account_circle, size: 35,))],),
      

      
      
      
      
      ) 
    );
       
  }
}