import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class OvertimeRequestScreen extends StatefulWidget {
  const OvertimeRequestScreen({super.key});

  @override
  State<OvertimeRequestScreen> createState() => _OvertimeRequestScreenState();
}

class _OvertimeRequestScreenState extends State<OvertimeRequestScreen> {
  final storage = const FlutterSecureStorage();
  
  DateTime? _selectedDate;
  final TextEditingController _hoursController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (pickedDate != null) {
      setState(() { _selectedDate = pickedDate; });
    }
  }

  Future<void> _submitOvertime() async {
    if (_selectedDate == null || _hoursController.text.isEmpty || _reasonController.text.isEmpty) {
      setState(() { _errorMessage = "Please fill in all fields."; });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      String? staffIdStr = await storage.read(key: "staffId");
      String? token = await storage.read(key: "token");

      if (staffIdStr == null) throw Exception("User not logged in.");

      final response = await http.post(
        Uri.parse('http://192.168.0.159:7205/api/Overtime/Submit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "staffId": int.parse(staffIdStr),
          "dateOfOvertime": _selectedDate!.toIso8601String(),
          "hoursRequested": double.parse(_hoursController.text),
          "reason": _reasonController.text,
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Overtime requested successfully!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        }
      } else {
        final data = jsonDecode(response.body);
        setState(() { _errorMessage = data['message'] ?? 'Failed to submit request.'; });
      }
    } catch (e) {
      setState(() { _errorMessage = 'Network error. Please check your connection.'; });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputDecoration = InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
      filled: true,
      fillColor: Colors.grey[200],
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Overtime Request'),
        backgroundColor: const Color(0xFF6c76cf),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Request Details', style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(_errorMessage, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ),

              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: inputDecoration.copyWith(prefixIcon: const Icon(Icons.calendar_today)),
                  child: Text(
                    _selectedDate == null 
                        ? 'Select Date of Overtime' 
                        : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                    style: TextStyle(color: _selectedDate == null ? Colors.grey[600] : Colors.black, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _hoursController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: inputDecoration.copyWith(hintText: 'Hours Requested (e.g. 2.5)', prefixIcon: const Icon(Icons.timer)),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _reasonController,
                maxLines: 4,
                decoration: inputDecoration.copyWith(
                  hintText: 'Reason for overtime (e.g. Weekend exam grading)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15), 
                    borderSide: BorderSide.none
                  ),
                ),
              ),
              const SizedBox(height: 40),

              Center(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitOvertime,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    minimumSize: const Size(300, 60),
                    backgroundColor: const Color(0xFF6c76cf),
                  ),
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text('Submit Request', style: GoogleFonts.notoSansAvestan(color: Colors.white, fontSize: 20)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}