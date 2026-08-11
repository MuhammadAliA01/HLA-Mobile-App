import 'package:flutter/material.dart';
import 'package:mobile_app/main.dart';
import 'package:mobile_app/screens/chatbot.dart';
import 'package:mobile_app/screens/studentactivities/activitydashboard.dart';
import 'package:mobile_app/screens/attendance/list.dart';
import 'package:mobile_app/screens/attendance/qrcamera.dart';
import 'package:mobile_app/screens/studentactivities/createactivity.dart';
import 'package:mobile_app/screens/medsadmin.dart';
import 'package:mobile_app/screens/student_grader.dart';
import 'package:mobile_app/screens/studentactivities/parenthomework.dart';
import '../account/login.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';



class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
 final storage = const FlutterSecureStorage();
  @override

void initState(){
  super.initState();
  checkLogin();
}

Future<void> checkLogin() async{

  final token = await storage.read(key: "token");

  if (token == null){
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Login()));
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf6f7fb),
      body: SingleChildScrollView(child: 
      SizedBox(
        width: double.infinity,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 40,
        
        children: [
          
          Padding(padding: EdgeInsets.only(left: 20, top: 20),
          child: Align(child:           
            Text('Welcome', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,), ),
            alignment: Alignment.centerLeft,
            ),
              ),
          
          

          

         InkWell(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (_) => ParentHomeworkScreen()));
            },
          child:  Ink(
            width: 400,
            height: 200,
            decoration: BoxDecoration(
              
              color: Colors.white,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: Colors.transparent,
                width: 2
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8
                )
              ]
            ),
            child: Column(
              children: [
                Expanded(child: 
                 Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.book, size: 50, color: Colors.deepOrange,),
                      Text('Homework', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), )
                    ],
                  ),
                )
                
                
                
                
              ],
            ),

          ),
          ),

          InkWell(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (_) => PerciApp()));
            },
          child:  Ink(
            width: 400,
            height: 200,
            decoration: BoxDecoration(
              
              color: Colors.white,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: Colors.transparent,
                width: 2
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8
                )
              ]
            ),
            child: Column(
              children: [
                Expanded(child: 
                 Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat, size: 50, color: Colors.deepOrange,),
                      Text('Chatbot', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), )
                    ],
                  ),
                )
                
                
                
                
              ],
            ),

          ),
          ),

        
        ],
      ),
      ) 
      ),
      
     
    );
  }
}







/* InkWell( //code to log out. Commented out since not needed rn
          onTap: () async {
            await storage.delete(key: 'token');
            
          },
          child: Container(
             width: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: Colors.grey
              )
            ),
            child: Column(
              
              children: [
                Icon(Icons.access_time, size: 50,),
                Text('LOG OUT', style: TextStyle(fontSize: 20),)
              ],
            ),
          ),
         ),*/