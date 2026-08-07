import 'package:flutter/material.dart';
import 'package:mobile_app/main.dart';
import 'package:mobile_app/screens/attendance/qrcamera.dart';
import 'account/login.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';



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
  }
}



  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 40,
        
        children: [
          Text('Welcome Teacher', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),),
          InkWell(
            onTap: (){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => QRScanner()));
            },
          child:  Container(
            width: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: Colors.grey,
                width: 1
              )
            ),
            child: Column(
              children: [
                Icon(Icons.accessibility_new_rounded, size: 50,),
                Text('Attendance', style: TextStyle(fontSize: 20),)
              ],
            ),

          ),
          ),
         
         InkWell(
          onTap: () {},
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
                Text('Clock In', style: TextStyle(fontSize: 20),)
              ],
            ),
          ),
         ),

          InkWell(
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
         ),

        
        ],
      ),
      ) 
     
    );
  }
}