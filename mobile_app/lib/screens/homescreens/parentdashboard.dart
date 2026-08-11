import 'package:flutter/material.dart';
import 'package:mobile_app/main.dart';
import 'package:mobile_app/screens/studentactivities/activitydashboard.dart';
import 'package:mobile_app/screens/attendance/list.dart';
import 'package:mobile_app/screens/attendance/qrcamera.dart';
import 'package:mobile_app/screens/studentactivities/createactivity.dart';
import 'package:mobile_app/screens/medsadmin.dart';
import 'package:mobile_app/screens/student_grader.dart';
import 'package:mobile_app/screens/studentactivities/parenthomework.dart';
import '../account/login.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_app/screens/medicationhistory.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;



class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
 final storage = const FlutterSecureStorage();
 int? studentId;
 bool isLoadingStudent = true;
  @override

void initState(){
  super.initState();
  checkLogin();
  getStudentForParent();
}

Future<void> checkLogin() async{

  final token = await storage.read(key: "token");

  if (token == null){
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Login()));
  }
}

Future<void> getStudentForParent() async {
  try {
    final parentId = await storage.read(key: "staffId");

    if (parentId == null) {
      debugPrint('No parent ID found.');
      return;
    }

    final response = await http.get(
      Uri.parse(
        'http://localhost:7205/api/MedsAdministered/parent/$parentId/student',
      ),
    );

    debugPrint('Student response: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      setState(() {
        studentId = data['studentId'];
        isLoadingStudent = false;
      });
    } else {
      debugPrint('Could not find student.');
      setState(() {
        isLoadingStudent = false;
      });
    }
  } catch (e) {
    debugPrint('Error getting student: $e');

    setState(() {
      isLoadingStudent = false;
    });
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
          

        //meds history card
        InkWell(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MedicationHistory(
          studentId: studentId!,
        ),
      ),
    );
  },

  child: Ink(
    width: 400,
    height: 200,

    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(11),
      border: Border.all(
        color: Colors.transparent,
        width: 2,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 8,
        ),
      ],
    ),

    child: Column(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [
              Icon(
                Icons.medication,
                size: 50,
                color: Colors.deepOrange,
              ),

              Text(
                'Medication History',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
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