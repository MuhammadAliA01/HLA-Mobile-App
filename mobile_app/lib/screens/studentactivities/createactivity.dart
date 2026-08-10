import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/services/notification_service.dart';

class CreateActivityScreen extends StatefulWidget {
  const CreateActivityScreen({super.key});

  @override
  State<CreateActivityScreen> createState() => _CreateActivityScreenState();
}

class _CreateActivityScreenState extends State<CreateActivityScreen> {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  final TextEditingController activityController =
      TextEditingController();

  List<dynamic> students = [];
  List<int> selectedStudentIDs = [];

  bool isLoading = true;
  bool isSending = false;

  @override
  void initState() {
    super.initState();
    loadStudents();
  }

  Future<void> loadStudents() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://localhost:7205/api/Activity/all',
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          students = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });

        print('Failed to load students');
        print(response.statusCode);
        print(response.body);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      print('Error loading students: $e');
    }
  }

  Future<void> sendActivity() async {
    if (activityController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an activity.'),
        ),
      );
      return;
    }

    if (selectedStudentIDs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one student.'),
        ),
      );
      return;
    }

    setState(() {
      isSending = true;
    });

    try {
      final staffID = await storage.read(key: 'staffId');

      if (staffID == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Teacher ID not found.'),
          ),
        );

        setState(() {
          isSending = false;
        });

        return;
      }

      final response = await http.post(
        Uri.parse(
          'http://localhost:7205/api/Activity/create',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'teacherID': int.parse(staffID),
          'homeworkDescription': activityController.text.trim(),
          'studentIDs': selectedStudentIDs,
        }),
      );

      print('STATUS CODE: ${response.statusCode}');
      print('RESPONSE BODY: ${response.body}');

      if (response.statusCode == 200) {
        activityController.clear();

        setState(() {
          selectedStudentIDs.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Activity assigned successfully!'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to assign activity: ${response.body}',
            ),
          ),
        );
      }
    } catch (e) {
      print('Error sending activity: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    }

    setState(() {
      isSending = false;
    });
  }

  @override
  void dispose() {
    activityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Activity'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              'Activity',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: activityController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Describe what the students should do...',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Select Students',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : students.isEmpty
                      ? const Center(
                          child: Text('No students found.'),
                        )
                      : ListView.builder(
                          itemCount: students.length,
                          itemBuilder: (context, index) {
                            final student = students[index];

                            final int studentID =
                                student['studentID'];

                            return CheckboxListTile(
                              title: Text(
                                '${student['firstName']}',
                              ),

                              value: selectedStudentIDs
                                  .contains(studentID),

                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    selectedStudentIDs
                                        .add(studentID);
                                  } else {
                                    selectedStudentIDs
                                        .remove(studentID);
                                  }
                                });
                              },
                            );
                          },
                        ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isSending
                    ? null
                    : sendActivity,
                child: isSending
                    ? const CircularProgressIndicator()
                    : const Text(
                        'Confirm Activity',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}