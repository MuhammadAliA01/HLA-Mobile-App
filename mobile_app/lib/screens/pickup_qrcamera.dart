import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class PickupQRScanner extends StatefulWidget {
  const PickupQRScanner({super.key});

  @override
  State<PickupQRScanner> createState() => _PickupQRScannerState();
}

class _PickupQRScannerState extends State<PickupQRScanner> {
  final MobileScannerController _scannerController =
      MobileScannerController();

  bool _hasScanned = false;

  void _handleBarcode(BarcodeCapture capture) {
    if (_hasScanned) return;

    final List<Barcode> barcodes = capture.barcodes;

    if (barcodes.isEmpty) return;

    final String? code = barcodes.first.rawValue;

    if (code == null || code.isEmpty) return;

    // Prevent multiple detections
    _hasScanned = true;

    // Stop the camera before leaving the page
    _scannerController.stop();

    // Return the scanned value
    Navigator.pop(context, code);
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Scan Teacher QR"),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _handleBarcode,
          ),

          // Scanner overlay
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

          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: const Text(
              "Position the teacher's QR code inside the box",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}