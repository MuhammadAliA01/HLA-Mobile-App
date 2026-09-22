import 'package:flutter/material.dart';
import 'package:mobile_app/main.dart';
import 'package:mobile_app/screens/attendance/list.dart';
import 'package:mobile_app/screens/attendance/qrcamera.dart';

class Already extends StatelessWidget {
  const Already({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Error', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.deepOrangeAccent,
      ),
        body: Center(child: 
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 20,
          children: [
          
           Icon(Icons.error_outline_outlined, size: 70, color: const Color.fromARGB(255, 255, 17, 0),),

            
           Text('Child Attendance Already Taken!', style: TextStyle(fontSize: 20),),

            
            
            InkWell(
              
              onTap: () {
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
                    child:Text('Go Back', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),textAlign: TextAlign.center,),

                  )
              ),
              )
              
            )
          ],
        ),
        )
        
    );
      


    
  }
}