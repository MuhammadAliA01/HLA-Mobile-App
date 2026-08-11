import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/screens/homescreens/parenthome.dart';
import 'dart:convert';
import 'dart:math';

import 'package:mobile_app/screens/pickup_qrcamera.dart';

class PickupConfirm extends StatefulWidget {
  final int studentID;
  final String? studentName;

  const PickupConfirm({super.key, required this.studentID, required this.studentName});

  @override
  State<PickupConfirm> createState() => _PickupConfirmState();
}

class _PickupConfirmState extends State<PickupConfirm> {

  Future<void> confirmPickupAPI(String type, String data) async {
    try {
      final response = await http.post(
        Uri.parse("http://192.168.0.159:7205/api/MobilePickup/confirmpickup"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "studentId": widget.studentID,
          "scannedData": data,
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Collection successful for ${widget.studentName}! Time logged.')),
          );
                        Navigator.push(context, MaterialPageRoute(builder: (_) => Parenthome()));

        }
      }
    } catch (e) {
       if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Network error. Could not reach server.')),
          );
        }
    }
  }

  void _generateDelegateCodeDialog() {
    String randomCode = (100000 + Random().nextInt(900000)).toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delegate Pickup Code"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Give this unique code to the person picking up your child. They will present it to the teacher."),
              const SizedBox(height: 20),
              Text(
                randomCode,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.deepOrange),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(context);
                confirmPickupAPI("DELEGATE", randomCode);
              },
              child: const Text("Confirm & Send"),
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf6f7fb),
      appBar: AppBar(
        title: Text('Pickup: ${widget.studentName ?? "Student"}'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.verified_user, size: 80, color: Colors.deepOrange),
              const SizedBox(height: 20),
              const Text("Confirm Student Pickup", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text(
                "Scan the teacher's daily QR code, or generate a delegate code.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              
              SizedBox(
                width: 400,
                height: 60,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.qr_code_scanner, size: 28),
                  label: const Text("Scan Teacher's QR Code", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange, 
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                  ),
                  onPressed: () async {
                    final scannedData = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PickupQRScanner()), 
                    );
if (scannedData != null && mounted) {
  await confirmPickupAPI(
    "QR",
    scannedData.toString(),
  );
}                  },
                ),
              ),
              const SizedBox(height: 20),
              
              SizedBox(
                width: 400,
                height: 60,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.vpn_key, size: 28),
                  label: const Text("Generate Delegate Code", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.deepOrange,
                    side: const BorderSide(color: Colors.deepOrange, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                  ),
                  onPressed: _generateDelegateCodeDialog,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}