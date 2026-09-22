import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class SubmitLeaveScreen extends StatefulWidget {
  const SubmitLeaveScreen({Key? key}) : super(key: key);

  @override
  State<SubmitLeaveScreen> createState() => _SubmitLeaveScreenState();
}

class _SubmitLeaveScreenState extends State<SubmitLeaveScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _reasonController =
      TextEditingController();

  final FlutterSecureStorage _storage =
      const FlutterSecureStorage();

  DateTime? _startDate;
  DateTime? _endDate;

  String _selectedLeaveType = 'Sick Leave';

  int? _availableDays;

  bool _isLoadingBalance = false;
  bool _isSubmitting = false;

  // Change this to your computer's IP address when testing
  // on a physical Android phone.
  final String baseUrl = 'http://192.168.0.159:7205';

  @override
  void initState() {
    super.initState();

    _loadInitialBalance();
  }

  @override
  void dispose() {
    _reasonController.dispose();

    super.dispose();
  }

  Future<int?> getLoggedInStaffId() async {
    String? staffIdString =
        await _storage.read(key: "staffId");

    if (staffIdString == null) {
      return null;
    }

    return int.tryParse(staffIdString);
  }

  int _getLeaveTypeIndex(String leaveType) {
    switch (leaveType) {
      case 'Sick Leave':
        return 0;

      case 'Family Responsibility':
        return 1;

      case 'Study Leave':
        return 2;

      case 'Annual Leave':
        return 3;

      default:
        return 0;
    }
  }

  Future<void> _loadInitialBalance() async {
    await _fetchAvailableDays(_selectedLeaveType);
  }

  Future<void> _fetchAvailableDays(String leaveType) async {
    setState(() {
      _isLoadingBalance = true;
      _availableDays = null;
    });

    try {
      final int? staffId = await getLoggedInStaffId();

      if (staffId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Could not find the logged-in staff ID.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }

        return;
      }

      final int leaveTypeIndex =
          _getLeaveTypeIndex(leaveType);

      final Uri url = Uri.parse(
        '$baseUrl/api/LeaveRequest/balance/'
        '$staffId/$leaveTypeIndex',
      );

      print('Getting leave balance from: $url');

      final response = await http.get(url);

      print(
        'Balance response status: ${response.statusCode}',
      );

      print(
        'Balance response body: ${response.body}',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(response.body);

        if (mounted) {
          setState(() {
            _availableDays =
                data['availableDays'];
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to load leave balance. '
                'Status: ${response.statusCode}',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Failed to load balance: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not connect to the server: $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingBalance = false;
        });
      }
    }
  }

  Future<void> _selectDate(
    BuildContext context,
    bool isStartDate,
  ) async {
    final DateTime? picked =
        await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked == null) {
      return;
    }

    setState(() {
      if (isStartDate) {
        _startDate = picked;

        if (_endDate != null &&
            _endDate!.isBefore(picked)) {
          _endDate = null;
        }
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _submitLeave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate == null ||
        _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select both dates.',
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'End date must be after start date.',
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    final int requestedDays =
        _endDate!
            .difference(_startDate!)
            .inDays +
        1;

    if (_availableDays != null &&
        requestedDays > _availableDays!) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You requested $requestedDays days, '
            'but only $_availableDays days are available.',
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final int? staffId =
          await getLoggedInStaffId();

      if (staffId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not find the logged-in staff ID.',
            ),
            backgroundColor: Colors.red,
          ),
        );

        return;
      }

      final int leaveTypeIndex =
          _getLeaveTypeIndex(
            _selectedLeaveType,
          );

      final Uri url = Uri.parse(
        '$baseUrl/api/LeaveRequest/submit',
      );

      final Map<String, dynamic> requestBody = {
        'staffId': staffId.toString(),
        'type': leaveTypeIndex,
        'startDate':
            _startDate!.toIso8601String(),
        'endDate':
            _endDate!.toIso8601String(),
        'reason':
            _reasonController.text.trim(),
      };

      print('Submitting leave request...');
      print('URL: $url');
      print(
        'Staff ID: $staffId',
      );
      print(
        'Request body: ${jsonEncode(requestBody)}',
      );

      final http.Response response =
          await http.post(
        url,
        headers: {
          'Content-Type':
              'application/json',
          'Accept':
              'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print(
        'Submit status: ${response.statusCode}',
      );

      print(
        'Submit response: ${response.body}',
      );

      if (!mounted) {
        return;
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data['message'] ??
                  'Leave request submitted successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );

        _reasonController.clear();

        setState(() {
          _startDate = null;
          _endDate = null;
        });

        await _fetchAvailableDays(
          _selectedLeaveType,
        );
      } else {
        String errorMessage =
            'Failed to submit leave request.';

        try {
          final Map<String, dynamic> data =
              jsonDecode(response.body);

          if (data['error'] != null) {
            errorMessage =
                data['error'].toString();
          }
        } catch (_) {
          if (response.body.isNotEmpty) {
            errorMessage = response.body;
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print(
        'Submit leave error: $e',
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not connect to the server: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Request Leave',
        ),
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
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              DropdownButtonFormField<String>(
                value: _selectedLeaveType,
                decoration: const InputDecoration(
                  labelText: 'Leave Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Sick Leave',
                    child: Text(
                      'Sick Leave',
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'Family Responsibility',
                    child: Text(
                      'Family Responsibility',
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'Study Leave',
                    child: Text(
                      'Study Leave',
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'Annual Leave',
                    child: Text(
                      'Annual Leave',
                    ),
                  ),
                ],
                onChanged: (String? newValue) {
                  if (newValue == null) {
                    return;
                  }

                  setState(() {
                    _selectedLeaveType =
                        newValue;
                  });

                  _fetchAvailableDays(
                    newValue,
                  );
                },
              ),

              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 16.0,
                ),
                child: _isLoadingBalance
                    ? const Align(
                        alignment:
                            Alignment.centerLeft,
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : Text(
                        'Your available days = '
                        '${_availableDays ?? "--"}',
                        style:
                            const TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                          color:
                              Colors.blueAccent,
                        ),
                      ),
              ),

              TextFormField(
                controller:
                    _reasonController,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Reason for Leave',
                  border:
                      OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Please enter a reason for your leave.';
                  }

                  return null;
                },
              ),

              const SizedBox(
                height: 20,
              ),

              ListTile(
                title: Text(
                  _startDate == null
                      ? 'Select Start Date'
                      : 'Start: '
                          '${_startDate!.toLocal()}'
                              .split(' ')[0],
                ),
                trailing:
                    const Icon(
                  Icons.calendar_today,
                ),
                shape:
                    RoundedRectangleBorder(
                  side:
                      const BorderSide(
                    color: Colors.grey,
                  ),
                  borderRadius:
                      BorderRadius.circular(4),
                ),
                onTap: () =>
                    _selectDate(
                  context,
                  true,
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              ListTile(
                title: Text(
                  _endDate == null
                      ? 'Select End Date'
                      : 'End: '
                          '${_endDate!.toLocal()}'
                              .split(' ')[0],
                ),
                trailing:
                    const Icon(
                  Icons.calendar_today,
                ),
                shape:
                    RoundedRectangleBorder(
                  side:
                      const BorderSide(
                    color: Colors.grey,
                  ),
                  borderRadius:
                      BorderRadius.circular(4),
                ),
                onTap: () =>
                    _selectDate(
                  context,
                  false,
                ),
              ),

              const SizedBox(
                height: 30,
              ),

              ElevatedButton(
                style:
                    ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                ),
                onPressed: _isSubmitting
                    ? null
                    : _submitLeave,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color:
                              Colors.white,
                        ),
                      )
                    : const Text(
                        'Submit Request',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}