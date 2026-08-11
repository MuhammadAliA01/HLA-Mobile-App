import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'medsadmin.dart';

class MedsStudentList extends StatefulWidget {
  const MedsStudentList({super.key});

  @override
  State<MedsStudentList> createState() => _MedsStudentListState();
}

class _MedsStudentListState extends State<MedsStudentList> {
  List students = [];

  @override
  void initState() {
    super.initState();
    getStudents();
  }

  Future<void> getStudents() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://192.168.0.159:7205/api/MedsAdministered/students',
        ),
      );

      print('STATUS: ${response.statusCode}');
      print('DATA: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          students = jsonDecode(response.body);
        });
      } else {
        print('ERROR GETTING STUDENTS');
      }
    } catch (e) {
      print('CONNECTION ERROR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select student'),
      ),
      body: students.isEmpty
          ? const Center(
              child: Text(
                'No students found',
                style: TextStyle(color: AppColors.textMuted, fontSize: 15),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: students.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final student = students[index];
                final String name = student['name'] ?? '';

                return Material(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      final int studentId = student['id'];

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MedsTrackingPage(
                            studentId: studentId,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          InitialsAvatar(name: name),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: AppColors.textMuted,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}