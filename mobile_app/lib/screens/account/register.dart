import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_app/screens/account/login.dart';
import 'package:mobile_app/main.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

String typedIdnum = '';
String typedFirstname = '';
String typedLastname = '';
String typedUsername = '';
String typedEmailname = '';
String typedPassword = '';
String errorMessage = '';

  @override
  Widget build(BuildContext context) {


Future<void> registerUser(String idNum, String firstName, String lastName,String username, String email, String password) async {

      const FlutterSecureStorage storage = FlutterSecureStorage();

      final response = await http.post(
     Uri.parse("http://localhost:7205/api/MobileAccount/register"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "idNumber": idNum,
        "firstname": firstName,
        "lastname": lastName,
        "username": username,
        "email": email,
        "password": password,
        
      }),
    );


print("Calling: http://localhost:7205/api/MobileAccount/register");  //
print("Status: ${response.statusCode}");
  print("Body: ${response.body}");
setState(() {
  errorMessage = response.body;
});
    if (response.statusCode == 200){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Login()),);
    }



    }








    return Scaffold(
             backgroundColor: Colors.white,
               resizeToAvoidBottomInset: false,

      appBar: AppBar(
        title: Text('Register', style: TextStyle(color: Colors.white),),
                backgroundColor: const Color.fromARGB(255, 241, 182, 105),

      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
              padding: EdgeInsets.all(20),


       child: Center(
        child: Column(
          
           crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 50,
          children: [
            Text('Register', style: GoogleFonts.manrope(fontSize: 40, color: Colors.black)),
            if (errorMessage.isNotEmpty)
              Text(errorMessage),
            SizedBox( 
              height: 50,
                            width: 300,

                child: TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.account_circle_outlined),
                hintText: 'ID Number',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Colors.black)
                
                ),
                
                filled: true,
                fillColor: const Color.fromARGB(255, 255, 255, 255)
               
              ),
              onChanged: (value){
                typedIdnum = value;
              },
            ),
            ),

            SizedBox( 
              height: 50,
                            width: 300,

                child: TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.account_circle_outlined),
                hintText: 'First Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Colors.black)
                
                ),
                
                filled: true,
                fillColor: const Color.fromARGB(255, 255, 255, 255)
               
              ),
              onChanged: (value){
                typedFirstname = value;
              },
            ),
            ),

            SizedBox( 
              height: 50,
                            width: 300,

                child: TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.account_circle_outlined),
                hintText: 'Last Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Colors.black)
                
                ),
                
                filled: true,
                fillColor: const Color.fromARGB(255, 255, 255, 255)
               
              ),
              onChanged: (value){
                typedLastname = value;
              },
            ),
            ),

            SizedBox( 
              height: 50,
                            width: 300,

                child: TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.account_circle_outlined),
                hintText: 'Username',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Colors.black)
                
                ),
                
                filled: true,
                fillColor: const Color.fromARGB(255, 255, 255, 255)
               
              ),
              onChanged: (value){
                typedUsername = value;
              },
            ),
            ),

            SizedBox( 
              height: 50,
                            width: 300,

                child: TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.account_circle_outlined),
                hintText: 'Email',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Colors.black)
                
                ),
                
                filled: true,
                fillColor: const Color.fromARGB(255, 255, 255, 255)
               
              ),
              onChanged: (value){
                typedEmailname = value;
              },
            ),
            ),
            
             SizedBox(
              height: 50,
              width: 300,
                child: TextField(
                  obscureText: true,
             
              decoration: InputDecoration(
               prefixIcon: Icon(Icons.lock_outline),
                hintText: 'Password',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Colors.black)

                ),
                     filled: true,
                fillColor: const Color.fromARGB(255, 255, 255, 255)

              ),
              onChanged: (value){
                typedPassword = value;
              },
            ),
            ),

            ElevatedButton(onPressed: () {registerUser(typedIdnum, typedFirstname, typedLastname, typedUsername, typedEmailname, typedPassword);},
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                minimumSize: Size(300, 60),
                backgroundColor: Colors.deepOrange
              ), child: Text('Create Account', style: GoogleFonts.notoSansAvestan(color: Colors.white, fontSize: 20),)   
          

            ),
        
              TextButton(onPressed: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Login()),);

              }, child: Text('Already have an account? Login', style: GoogleFonts.averageSans(color: Colors.deepOrange, fontSize: 13, fontWeight: FontWeight.bold),),
            
            ),
            


          ],
         
        ),
       )
          )
        )
        

      ),
    );
  }
}