import 'package:flutter/material.dart';
import 'package:mobile_app/main.dart';
import 'package:mobile_app/screens/homescreens/parenthome.dart';
import 'package:mobile_app/screens/meds_qr_scanner.dart';
import 'package:mobile_app/screens/medsstudentlist.dart';
import 'package:mobile_app/screens/studentactivities/activitydashboard.dart';
import 'package:mobile_app/screens/attendance/list.dart';
import 'package:mobile_app/screens/attendance/qrcamera.dart';
import 'package:mobile_app/screens/studentactivities/createactivity.dart';
import 'package:mobile_app/screens/medsadmin.dart';
import 'package:mobile_app/screens/student_grader.dart';
import 'package:mobile_app/screens/studentactivities/parenthomework.dart';
import 'package:mobile_app/screens/teacher_pickup.dart';
import '../account/login.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';



class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
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

    return;
  }

  if (JwtDecoder.isExpired(token)){
    await storage.delete(key: 'token');

    return;
  }

  final decodedToken = JwtDecoder.decode(token);

  print(decodedToken);

  final role = decodedToken["role"]?.toString().trim();

  if (role == 'Staff'){
      return;
  }
  else if (role == 'Parent'){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Parenthome()));

        return;
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
          child: Align(alignment: Alignment.centerLeft,child:           
            Text('Welcome', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,), ),
            ),
              ),
          
          InkWell(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (_) => ClassList()));
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
                      Icon(Icons.accessibility_new_rounded, size: 50, color: Colors.deepOrange,),
                      Text('Attendance', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), )
                    ],
                  ),
                )
                
                
                
                
              ],
            ),

          ),
          ),

          InkWell(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (_) => const MedsQRScanner()));
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
                      Icon(Icons.medical_services, size: 50, color: Colors.deepOrange,),
                      Text('Meds Tracking', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), )
                    ],
                  ),
                )
                
                
                
                
              ],
            ),

          ),
          ),

          InkWell(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (_) => ActivityDashboard()));
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
              Navigator.push(context, MaterialPageRoute(builder: (_) => TeacherPickupScreen()));
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
                      Icon(Icons.car_crash_sharp, size: 50, color: Colors.deepOrange,),
                      Text('Confirm Pickup', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), )
                    ],
                  ),
                )
                
                
                
                
              ],
            ),

          ),
          ),


          


          


         

          /*InkWell( //code to log out. Commented out since not needed rn
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

      

        
        ],
      ),
      ) 
      )
      
     
    );
  }
}