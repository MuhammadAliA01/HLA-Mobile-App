import 'package:flutter/material.dart';
import 'package:mobile_app/main.dart';
import 'package:mobile_app/screens/attendance/list.dart';
import 'package:mobile_app/screens/attendance/qrcamera.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';




class Confirm extends StatefulWidget {

final int studentID;
final int? staffID;
final String? studentName;


  const Confirm({super.key, required this.studentID, required this.staffID, required this.studentName});

  @override
  State<Confirm> createState() => _ConfirmState();
}

class _ConfirmState extends State<Confirm> {

  bool isPressed = false;

  @override
  Widget build(BuildContext context) {

    Future<void> logAttend(int StudentID, int TeacherID) async {

      const FlutterSecureStorage storage = FlutterSecureStorage();

      final response = await http.post(
     Uri.parse("http://localhost:7205/api/MobileAttendance/logattendance"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "studentID": StudentID,
        "teacherID": TeacherID,
        
      }),
    );

print("STATUS CODE: ${response.statusCode}");
print("RESPONSE BODY: ${response.body}");
  
    if (response.statusCode == 200){
      final data = jsonDecode(response.body);

      print(data);

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MyApp()),);

      
    }



    }



    return Scaffold(
      appBar: AppBar(
        title: Text('Confirm ${widget.studentName} Attendance', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.deepOrangeAccent,
      ),
        body: Center(child: 
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 20,
          children: [
          
           Icon(isPressed ? Icons.check_box : Icons.question_mark, size: 70, color: const Color.fromARGB(255, 255, 17, 0),
           
            
           ),

            
           Text( isPressed ? 'Attendance Taken Please Wait!' : 'Confirm ${widget.studentName} Attendance?!', style: TextStyle(fontSize: 20),),

            
            if(!isPressed)
              InkWell(
              
              onTap: () async {
                setState(() {
                  isPressed = !isPressed;
                });
                logAttend(widget.studentID, widget.staffID!);

                await Future.delayed(Duration(seconds: 3));

                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ClassList()));
              },
              child: 
              SizedBox(
                
                height: 50,
                width: 200,
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.transparent),
                    color: Colors.deepOrange
                  ),
                  child: Center(
                    child:Text('Confirm', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),textAlign: TextAlign.center,),

                  )
              ),
              )
              
            )
            else if (isPressed)
              Center(
                child: CircularProgressIndicator(),
              )
          ],
        ),
        )
        
    );
  }
}

// final String studentID;
  //final String? staffID;logAttend(widget.studentID, widget.staffID!);