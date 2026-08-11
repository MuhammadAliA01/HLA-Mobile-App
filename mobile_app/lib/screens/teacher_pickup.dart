import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; 
import 'package:qr_flutter/qr_flutter.dart'; 

class TeacherPickupScreen extends StatefulWidget {
  const TeacherPickupScreen({super.key});

  @override
  State<TeacherPickupScreen> createState() => _TeacherPickupScreenState();
}

class _TeacherPickupScreenState extends State<TeacherPickupScreen> {
  String? dailyQrCodeData;
  final TextEditingController _delegateCodeController = TextEditingController();

  
  void _generateDailyCode() {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    setState(() {
      
      dailyQrCodeData = "PICKUP_AUTH_$today"; 
    });
  }

  
  Future<void> _verifyDelegateCode() async {
    final code = _delegateCodeController.text.trim();
    if (code.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse("[http://192.168.0.159:7205/api/MobilePickup/verifydelegate]"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"delegateCode": code}),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Delegate Code Verified! Student released.')),
          );
          _delegateCodeController.clear();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid code. Please check and try again.')),
          );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf6f7fb),
      appBar: AppBar(
        title: const Text('Manage Student Pickups'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- SECTION 1: DAILY QR CODE ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(11),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)],
              ),
              child: Column(
                children: [
                  const Icon(Icons.qr_code, size: 50, color: Colors.deepOrange),
                  const SizedBox(height: 10),
                  const Text("Daily Parent Pickup Code", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text("Generate the daily code for parents to scan.", textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  
                  if (dailyQrCodeData != null)
                    Column(
                      children: [
                        // THIS IS WHERE THE REAL QR CODE IS DRAWN!
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(11),
                            border: Border.all(color: Colors.deepOrange, width: 2),
                          ),
                          child: QrImageView(
                            data: dailyQrCodeData!,
                            version: QrVersions.auto,
                            size: 200.0,
                            backgroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text("Active for today only", style: TextStyle(color: Colors.grey)),
                      ],
                    )
                  else
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                        minimumSize: const Size(double.infinity, 50)
                      ),
                      onPressed: _generateDailyCode,
                      child: const Text("Generate Today's Code"),
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),

            // --- SECTION 2: DELEGATE PICKUP PIN ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(11),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)],
              ),
              child: Column(
                children: [
                  const Icon(Icons.people_alt, size: 50, color: Colors.deepOrange),
                  const SizedBox(height: 10),
                  const Text("Delegate Pickup", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text("Enter the unique 6-digit code provided.", textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  
                  TextField(
                    controller: _delegateCodeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Enter Delegate Code',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(11)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(11),
                        borderSide: const BorderSide(color: Colors.deepOrange, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.deepOrange,
                      side: const BorderSide(color: Colors.deepOrange, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                      minimumSize: const Size(double.infinity, 50)
                    ),
                    onPressed: _verifyDelegateCode,
                    child: const Text("Verify Code & Release Child"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}