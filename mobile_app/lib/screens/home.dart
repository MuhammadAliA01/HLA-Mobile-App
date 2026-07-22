import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
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
            onTap: (){},
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
         )

          
        ],
      ),
      ) 
     
    );
  }
}