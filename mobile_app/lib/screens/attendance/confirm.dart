import 'package:flutter/material.dart';
import 'package:mobile_app/main.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';




class Confirm extends StatefulWidget {

final int studentID;
final int? staffID;


  const Confirm({super.key, required this.studentID, required this.staffID});

  @override
  State<Confirm> createState() => _ConfirmState();
}

class _ConfirmState extends State<Confirm> {
  @override
  Widget build(BuildContext context) {

    Future<void> logAttend(int StudentID, int TeacherID) async {

      const FlutterSecureStorage storage = FlutterSecureStorage();

      final response = await http.post(
     Uri.parse("http://192.168.0.159:7205/api/MobileAttendance/logattendance"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "studentID": StudentID,
        "teacherID": TeacherID,
        
      }),
    );

  
    if (response.statusCode == 200){
      final data = jsonDecode(response.body);

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MyApp()),);
    }



    }



    return Scaffold(
      body: 
      Center(
        child: Container(
           child: InkWell(
              child: Text('Log Attendance'),
                onTap: () {
                  logAttend(widget.studentID, widget.staffID!);
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MyApp()));
        },
      ),
        )
       
      )
      


    );
  }
}

// final String studentID;
  //final String? staffID;