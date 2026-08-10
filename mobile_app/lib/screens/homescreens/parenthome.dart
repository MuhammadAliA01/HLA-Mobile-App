import 'package:flutter/material.dart';
import 'package:mobile_app/main.dart';
import 'package:mobile_app/screens/calendar.dart';
import 'package:mobile_app/screens/homescreens/parentdashboard.dart';
import 'package:mobile_app/screens/studentactivities/activitydashboard.dart';
import 'package:mobile_app/screens/attendance/list.dart';
import 'package:mobile_app/screens/attendance/qrcamera.dart';
import 'package:mobile_app/screens/studentactivities/createactivity.dart';
import 'package:mobile_app/screens/medsadmin.dart';
import 'package:mobile_app/screens/student_grader.dart';
import 'package:mobile_app/screens/studentactivities/parenthomework.dart';
import '../account/login.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';



class Parenthome extends StatefulWidget {
  const Parenthome({super.key});

  @override
  State<Parenthome> createState() => _ParenthomeState();
}

class _ParenthomeState extends State<Parenthome> {

      final storage = const FlutterSecureStorage();


  int selectedIndex = 0; 

  
  final List<Widget> pages = const [
    ParentDashboard(),
    ParentHomeworkScreen()
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.orangeAccent,
        actions: [
            PopupMenuButton(
              onSelected: (value) async { if (value == 'Log Out'){
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Login()));
                 await storage.delete(key: 'token');
              }},
              icon: const Icon(Icons.account_circle, size: 35, color: Colors.black45,),
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(value: 'Log Out', child: Text('Log Out'))
              ],
            ),
          ],
      ),
      backgroundColor: const Color(0xFFf6f7fb),
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
            BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Homework'),


          ],
        ),
    );


  }
}