import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_app/main.dart';
import 'package:mobile_app/screens/attendance/alreadyatt.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mobile_app/screens/attendance/confirm.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';



class QRScanner extends StatefulWidget {
  const QRScanner({super.key});

  @override
  State<QRScanner> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {

  final MobileScannerController controller = MobileScannerController();
  bool scanned = false;


 String responsecode = '';


 

  @override
  Widget build(BuildContext context) {

      Future<void> checkAttend(int StudentID) async {

      const FlutterSecureStorage storage = FlutterSecureStorage();

      final response = await http.post(
     Uri.parse("http://localhost:7205/api/MobileAttendance/checkattendance"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "studentID": StudentID,
        
      }),
    );

print("STATUS CODE: ${response.statusCode}");
print("RESPONSE BODY: ${response.body}");
  
    if (response.statusCode == 200){
      responsecode = response.body.trim();
  print(responsecode);


      
    }



    }













    return Scaffold(
        appBar:AppBar(
          title: Text('Scan QR Code'),
        ),
        body: MobileScanner(
          controller: controller,
          onDetect: (capture) async {
            if (scanned) return;

            final Barcode? barcode = capture.barcodes.firstOrNull;

            

            if (barcode != null && barcode.rawValue != null){
              scanned = true;


              String qrValueString = barcode.rawValue.toString();
              int? qrValue = int.tryParse(qrValueString);

              List<String> parts = qrValueString.split('|');


              int? studentID = int.tryParse(parts[0]);

              String studentName = parts[1];


              controller.stop();

                const FlutterSecureStorage storage = FlutterSecureStorage();
                
                String? staffIDString = await storage.read(key: "staffId");
                int? staffID = int.tryParse(staffIDString!);

                await checkAttend(studentID!);

                if (responsecode == 'Correct'){
              Navigator.push(context, MaterialPageRoute(builder: (_) => Confirm(studentID: studentID, staffID: staffID, studentName: studentName,)));

                }
                else if (responsecode == 'Attendance Already taken'){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Already()));

                }

            }
          },
        ),


    );
  }

  @override
  void dispose(){
    controller.dispose();
    super.dispose();
  }
}