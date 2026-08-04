import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_app/screens/account/register.dart';
import 'package:mobile_app/screens/home.dart';
import 'package:mobile_app/main.dart';


class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

List<String> options = ['Teacher', 'Parent'];
class _LoginState extends State<Login> {

      String currentOption = options[0];
      String typedUsername = '';
    String typedPassword = '';
    String errorMessage = '';


  @override
  Widget build(BuildContext context) {

    


    Future<void> loginUser(String username, String password, String role) async {

      const FlutterSecureStorage storage = FlutterSecureStorage();

      final response = await http.post(
     Uri.parse("https://localhost:7205/api/MobileAccount/Login"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "username": username,
        "password": password,
        "role": role,
      }),
    );

  
    if (response.statusCode == 200){
      final data = jsonDecode(response.body);

      await storage.write(key: "token", value: data["token"]);
      await storage.write(key: "staffId", value: data["staffId"].toString());
      await storage.write(key: "staffName", value: data["firstName"].toString());
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MyApp()),);
    }

 setState(() {
  errorMessage = response.body;
});


    }


    return Scaffold(
             backgroundColor: Colors.transparent,
               resizeToAvoidBottomInset: false,

      appBar: AppBar(
        title: Text('Login'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/imgs/loginBG.jpg'
          ),
          fit: BoxFit.cover
          ),
        ),


       child: Center(
        child: Column(
          
           crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 40,
          children: [
            Text('Welcome', style: GoogleFonts.manrope(fontSize: 50, color: const Color.fromARGB(255, 255, 255, 255))),

          if (errorMessage.isNotEmpty)
            Text(errorMessage)
        


            ,
            SizedBox( 
              height: 50,
                            width: 300,

                child: TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.account_circle_outlined),
                hintText: 'Username',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none
                
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
               prefixIcon: Icon(Icons.lock_outline),
                hintText: 'Password',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30),
               borderSide: BorderSide.none

                ),
                     filled: true,
                fillColor: const Color.fromARGB(255, 255, 255, 255)

              ),
              onChanged: (value){
                typedPassword = value;
              },
            ),
            ),
            Row(
              children: [
              Radio<String>(
              value: options[0],
              groupValue: currentOption,
              onChanged: (value) {
                setState(() {
                  currentOption = value.toString();
                });
              },
               
            
                  
            ),
            Text('Teacher'),
            SizedBox(width: 20,),
          Radio(
              value: options[1],
              groupValue: currentOption,
              onChanged: (value) {
                setState(() {
                  currentOption = value.toString();
                });
              },
               
            ),
            Text('Parent')
         
            
              ],
            ),
            


            ElevatedButton(onPressed: () { print("Button pressed"); loginUser(typedUsername, typedPassword, currentOption);},
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                minimumSize: Size(300, 60),
                backgroundColor: const Color(0xFF6c76cf)
              ), child: Text('Login', style: GoogleFonts.notoSansAvestan(color: Colors.white, fontSize: 20),)   
          

            ),
          

              TextButton(onPressed: () {Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Register()));}, child: Text('Dont have an Account? Register', style: GoogleFonts.averageSans(color: const Color.fromARGB(255, 161, 161, 230), fontSize: 13, fontWeight: FontWeight.bold),),
            
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