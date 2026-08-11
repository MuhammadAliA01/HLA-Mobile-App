import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'medsadmin.dart';

class MedsQRScanner extends StatefulWidget {
  const MedsQRScanner({super.key});

  @override
  State<MedsQRScanner> createState() => _MedsQRScannerState();
}

class _MedsQRScannerState extends State<MedsQRScanner> {
  final MobileScannerController _controller =
      MobileScannerController();

  bool _isProcessing = false;

  void _processQRCode(String? value) {
    if (_isProcessing) {
      return;
    }

    if (value == null || value.trim().isEmpty) {
      return;
    }

    final String qrValue = value.trim();

    debugPrint('=================================');
    debugPrint('MEDICATION QR SCANNED');
    debugPrint('QR VALUE: $qrValue');
    debugPrint('=================================');

    /*
      Your backend generates QR data like:

      25|John Smith

      25 = StudentId
      John Smith = Student name
    */

    final List<String> parts = qrValue.split('|');

    if (parts.isEmpty) {
      _showInvalidQR();
      return;
    }

    final int? studentId = int.tryParse(parts[0].trim());

    if (studentId == null) {
      debugPrint('Invalid student ID in QR code.');
      _showInvalidQR();
      return;
    }

    debugPrint('Student ID: $studentId');

    _isProcessing = true;

    // Stop camera before navigating.
    _controller.stop();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MedsTrackingPage(
          studentId: studentId,
        ),
      ),
    );
  }

  void _showInvalidQR() {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Invalid student QR code.',
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Student QR'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () {
              _controller.toggleTorch();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // ==========================================
          // CAMERA
          // ==========================================

          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              for (final barcode in capture.barcodes) {
                final String? value = barcode.rawValue;

                if (value != null) {
                  _processQRCode(value);
                  break;
                }
              }
            },
          ),

          // ==========================================
          // SCANNER BOX
          // ==========================================

          Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),

          // ==========================================
          // INSTRUCTION
          // ==========================================

          Positioned(
            left: 20,
            right: 20,
            bottom: 70,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.65),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Scan the student QR code',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}