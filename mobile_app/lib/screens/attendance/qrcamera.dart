import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mobile_app/screens/attendance/confirm.dart';


class QRScanner extends StatefulWidget {
  const QRScanner({super.key});

  @override
  State<QRScanner> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {

  final MobileScannerController controller = MobileScannerController();
  bool scanned = false;




  @override
  Widget build(BuildContext context) {
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
              int? qrValue = int.tryParse(qrValueString!);

              List<String> parts = qrValueString.split('|');


              int? studentID = int.tryParse(parts[0]);

              String studentName = parts[1];


              controller.stop();

                const FlutterSecureStorage storage = FlutterSecureStorage();
                
                String? staffIDString = await storage.read(key: "staffId");
                int? staffID = int.tryParse(staffIDString!);

              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Confirm(studentID: studentID!, staffID: staffID, studentName: studentName,)));
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