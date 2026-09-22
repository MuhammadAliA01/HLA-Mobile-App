import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/leave_request.dart';

class SubmitLeaveScreen extends StatefulWidget {
  const SubmitLeaveScreen({Key? key}) : super(key: key);

  @override
  State<SubmitLeaveScreen> createState() => _SubmitLeaveScreenState();
}

class _SubmitLeaveScreenState extends State<SubmitLeaveScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _reasonController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedLeaveType = 'Sick Leave';

  // NEW: State variables to hold the balance
  int? _availableDays;
  bool _isLoadingBalance = false;

  @override
  void initState() {
    super.initState();
    // NEW: Fetch balance immediately when the screen loads
    _fetchAvailableDays(_selectedLeaveType);
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  // NEW: Function to ask C# for the balance
  Future<void> _fetchAvailableDays(String leaveType) async {
    setState(() {
      _isLoadingBalance = true;
    });

    // Map the dropdown string to your C# Enum index
    int leaveTypeIndex = 0; // Default: Sick Leave
    if (leaveType == 'Family Responsibility') leaveTypeIndex = 1;
    if (leaveType == 'Study Leave') leaveTypeIndex = 2;
    if (leaveType == 'Annual Leave') leaveTypeIndex = 3;

    try {
      // NOTE: 10.0.2.2 is how Android Emulators connect to localhost on your PC!
      // Make sure the port (7123) matches the one Visual Studio actually launched on.
      final url = Uri.parse('https://10.0.2.2:7123/api/LeaveRequest/balance/999/$leaveTypeIndex');
      
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _availableDays = data['availableDays'];
        });
      }
    } catch (e) {
      print('Failed to load balance: $e');
    } finally {
      setState(() {
        _isLoadingBalance = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Leave'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Fill out your leave details below:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              
              DropdownButtonFormField<String>(
                value: _selectedLeaveType,
                decoration: const InputDecoration(
                  labelText: 'Leave Type',
                  border: OutlineInputBorder(),
                ),
                items: <String>[
                  'Sick Leave',
                  'Family Responsibility',
                  'Study Leave',
                  'Annual Leave'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedLeaveType = newValue!;
                  });
                  // NEW: Refetch the balance when the user changes the dropdown!
                  _fetchAvailableDays(_selectedLeaveType);
                },
              ),
              
              // NEW: The UI text showing the available days
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: _isLoadingBalance 
                    ? const Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: 20, 
                          height: 20, 
                          child: CircularProgressIndicator(strokeWidth: 2)
                        ),
                      )
                    : Text(
                        'Your available days is = ${_availableDays ?? "--"}',
                        style: const TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.bold, 
                          color: Colors.blueAccent
                        ),
                      ),
              ),

              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason for Leave',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a reason for your leave.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ListTile(
                title: Text(_startDate == null
                    ? 'Select Start Date'
                    : 'Start: ${_startDate!.toLocal()}'.split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                onTap: () => _selectDate(context, true),
              ),
              const SizedBox(height: 10),
              ListTile(
                title: Text(_endDate == null
                    ? 'Select End Date'
                    : 'End: ${_endDate!.toLocal()}'.split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                onTap: () => _selectDate(context, false),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (_startDate == null || _endDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select both dates')),
                      );
                      return;
                    }

                    LeaveType selectedEnum;
                    switch (_selectedLeaveType) {
                      case 'Family Responsibility':
                        selectedEnum = LeaveType.familyResponsibility;
                        break;
                      case 'Study Leave':
                        selectedEnum = LeaveType.studyLeave;
                        break;
                      case 'Annual Leave':
                        selectedEnum = LeaveType.annualLeave;
                        break;
                      default:
                        selectedEnum = LeaveType.sickLeave;
                    }

                    try {
                      final newRequest = LeaveRequest.submit(
                        staffId: '999',
                        type: selectedEnum,
                        startDate: _startDate!,
                        endDate: _endDate!,
                        reason: _reasonController.text,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Success! Leave requested.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e.toString().replaceAll('Invalid argument(s): ', '')),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Submit Request', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 