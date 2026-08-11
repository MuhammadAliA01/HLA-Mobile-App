import 'package:flutter/material.dart';
import 'package:mobile_app/main.dart';
import 'package:mobile_app/screens/attendance/qrcamera.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ClassList extends StatefulWidget {
  const ClassList({super.key});

  @override
  State<ClassList> createState() => _ClassListState();
}

class _ClassListState extends State<ClassList> {

  Color primaryColor = Colors.green;
    Color secColor = Colors.red;


  @override
  void initState(){
    super.initState();
      print("INIT STATE RUNNING");
    logAttend();
  }
  

   Future<void> logAttend() async {

      const FlutterSecureStorage storage = FlutterSecureStorage();

      final response = await http.get(
     Uri.parse("http://localhost:7205/api/MobileAttendance/classlist"),
      headers: {
        "Content-Type": "application/json",
      },
      
    );

  
    if (response.statusCode == 200){
      final data = jsonDecode(response.body);

      print(data);

        setState(() {
          items = data;
        });
    }



    }

    List<dynamic> items = [];
  @override
  Widget build(BuildContext context) {

  

    Future<void> logAttend() async {


      const FlutterSecureStorage storage = FlutterSecureStorage();

      final response = await http.get(
     Uri.parse("http://localhost:7205/api/MobileAttendance/classlist"),
      headers: {
        "Content-Type": "application/json",
      },
      
    );

  
    if (response.statusCode == 200){
      final data = jsonDecode(response.body);

      print(data);

        items = jsonDecode(data);
    }



    }






    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        backgroundColor: const Color.fromARGB(255, 241, 182, 105),
      ),
          body:
          SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: 
            Center(
            child: Container(
              child: SizedBox(
                width: 600,
                child: Column(
                  spacing: 30,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
            children:
            [
              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => QRScanner()));
                },
                  child: 
                  SizedBox(
                    width: 300,
                    height: 70,
                    child: 
                    Ink(
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(11)
                    ),
                    child: Container(
                     child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 50,
                      children: [
                        Text('Take Attendance', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),)
                      ],
                    ),
                  ),
                  )
                 
                  )
                  
              ),
              ...items.map((item){
                if (item["status"] == "Present"){
                    primaryColor = Colors.green;
                  
                }
                else if (item["status"] == "Absent"){
                    primaryColor = Colors.red;

                }

                return SizedBox(
                  width: 600,
                  child: Card(
                  color: Colors.white,
                  child: ListTile(
                  title: Text(item["name"], style: TextStyle(fontSize: 20),),
                  subtitle: Text(item["status"] , style: TextStyle(fontSize: 15, color: primaryColor), ),
                  contentPadding: EdgeInsets.all(30),
                  
                ),
                ),
                );
                
                
              }).toList(), 
              
              ]
          ),
              )
              
            ),
          ) ,
          )
          
          
      );
  }
}

