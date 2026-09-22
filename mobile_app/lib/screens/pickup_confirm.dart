import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/screens/homescreens/parenthome.dart';
import 'package:mobile_app/screens/pickup_qrcamera.dart';

class PickupConfirm extends StatefulWidget {
  final int studentID;
  final String? studentName;

  const PickupConfirm({
    super.key,
    required this.studentID,
    required this.studentName,
  });

  @override
  State<PickupConfirm> createState() => _PickupConfirmState();
}

class _PickupConfirmState extends State<PickupConfirm> {
  // ==========================================================
  // CONFIRM PICKUP USING TEACHER QR CODE
  // ==========================================================

  Future<void> confirmPickupAPI(String scannedData) async {
    try {
      final response = await http.post(
        Uri.parse(
          "http://localhost:7205/api/MobilePickup/confirmpickup",
        ),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "studentId": widget.studentID,
          "scannedData": scannedData,
        }),
      );

      debugPrint("QR Pickup Status: ${response.statusCode}");
      debugPrint("QR Pickup Response: ${response.body}");

      if (response.statusCode == 200) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Collection successful for ${widget.studentName}! Time logged.",
            ),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => Parenthome(),
          ),
        );
      } else {
        String message = "Pickup failed.";

        try {
          final responseData = jsonDecode(response.body);

          if (responseData["message"] != null) {
            message = responseData["message"].toString();
          }
        } catch (_) {}

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
          ),
        );
      }
    } catch (e) {
      debugPrint("QR Pickup Error: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Network error: $e"),
        ),
      );
    }
  }

  // ==========================================================
  // CREATE DELEGATE CODE
  // ==========================================================

  Future<void> createDelegateCode(String code) async {
    try {
      final response = await http.post(
        Uri.parse(
          "http://localhost:7205/api/MobilePickup/createdelegate",
        ),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "studentId": widget.studentID,
          "delegateCode": code,
        }),
      );

      debugPrint("Delegate Status: ${response.statusCode}");
      debugPrint("Delegate Response: ${response.body}");

      if (response.statusCode == 200) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Delegate code created for ${widget.studentName}.",
            ),
          ),
        );
      } else {
        String message = "Could not create delegate code.";

        try {
          final responseData = jsonDecode(response.body);

          if (responseData["message"] != null) {
            message = responseData["message"].toString();
          }
        } catch (_) {}

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
          ),
        );
      }
    } catch (e) {
      debugPrint("Create Delegate Error: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Network error: $e"),
        ),
      );
    }
  }

  // ==========================================================
  // GENERATE DELEGATE CODE DIALOG
  // ==========================================================

  void _generateDelegateCodeDialog() {
    final String randomCode =
        (100000 + Random().nextInt(900000)).toString();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Delegate Pickup Code"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Give this unique code to the person picking up your child. "
                "They will present it to the teacher.",
              ),
              const SizedBox(height: 20),
              Text(
                randomCode,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                  letterSpacing: 4,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("Close"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.pop(dialogContext);

                await createDelegateCode(randomCode);
              },
              child: const Text("Confirm & Send"),
            ),
          ],
        );
      },
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: Text(
          "Pickup: ${widget.studentName ?? "Student"}",
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.verified_user,
                size: 80,
                color: Colors.deepOrange,
              ),

              const SizedBox(height: 20),

              const Text(
                "Confirm Student Pickup",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Scan the teacher's daily QR code, "
                "or generate a delegate code.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 40),

              // ==================================================
              // SCAN QR CODE
              // ==================================================

              SizedBox(
                width: 400,
                height: 60,
                child: ElevatedButton.icon(
                  icon: const Icon(
                    Icons.qr_code_scanner,
                    size: 28,
                  ),
                  label: const Text(
                    "Scan Teacher's QR Code",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  onPressed: () async {
                    final scannedData = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const PickupQRScanner(),
                      ),
                    );

                    if (scannedData != null && mounted) {
                      await confirmPickupAPI(
                        scannedData.toString(),
                      );
                    }
                  },
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // DELEGATE CODE
              // ==================================================

              SizedBox(
                width: 400,
                height: 60,
                child: OutlinedButton.icon(
                  icon: const Icon(
                    Icons.vpn_key,
                    size: 28,
                  ),
                  label: const Text(
                    "Generate Delegate Code",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.deepOrange,
                    side: const BorderSide(
                      color: Colors.deepOrange,
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
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