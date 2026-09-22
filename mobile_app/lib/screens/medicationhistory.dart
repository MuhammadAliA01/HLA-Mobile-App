import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class MedicationHistory extends StatefulWidget {
  final int studentId;

  const MedicationHistory({
    super.key,
    required this.studentId,
  });

  @override
  State<MedicationHistory> createState() => _MedicationHistoryState();
}

class _MedicationHistoryState extends State<MedicationHistory> {
  List medications = [];
  bool isLoading = true;
  String studentName = '';

  @override
  void initState() {
    super.initState();
    getMedicationHistory();
    getStudentName();
  }

  Future<void> getMedicationHistory() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://localhost:7205/api/MedsAdministered/student/${widget.studentId}/history',
        ),
      );

      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('DATA: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          medications = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });

        debugPrint('Error getting medication history');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      debugPrint('Connection error: $e');
    }
  }

  Future<void> getStudentName() async {
  try {
    final response = await http.get(
      Uri.parse(
        'http://localhost:7205/api/MedsAdministered/students',
      ),
    );

    if (response.statusCode == 200) {
      final List students = jsonDecode(response.body);

      for (var student in students) {
        if (student['id'] == widget.studentId) {
          setState(() {
            studentName = student['name'];
          });

          break;
        }
      }
    }
  } catch (e) {
    debugPrint('Error getting student name: $e');
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),

      appBar: AppBar(
        title: const Text('Medication History'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 239, 123, 87),
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : medications.isEmpty
              ? const Center(
                  child: Text(
                    'No medication records found.',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      // report titlr
                      const Text(
                        'Medication Administration Report',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        studentName.isEmpty
                            ? 'Medication records for your child'
                            : 'Medication records for $studentName',
                         style: const TextStyle(
                           fontSize: 14,
                           color: Colors.grey,
                       ),
                    ),

                      const SizedBox(height: 20),

                      
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),

                          child: Row(
                            children: [

                              const Icon(
                                Icons.medication,
                                size: 40,
                                color: Color.fromARGB(255, 255, 126, 87),
                              ),

                              const SizedBox(width: 16),

                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,

                                children: [

                                  const Text(
                                    'Total Administrations',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    '${medications.length}',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // the table
                      Card(
                        elevation: 2,

                        child: Padding(
                          padding: const EdgeInsets.all(12),

                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,

                            children: [

                              const Text(
                                'Administration Records',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 12),

                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,

                                child: DataTable(
                                  headingRowColor:
                                      WidgetStateProperty.all(
                                    const Color.fromARGB(255, 239, 123, 87),
                                  ),

                                  columns: const [

                                    DataColumn(
                                      label: Text(
                                        'Date',
                                        style: TextStyle(
                                          fontWeight:
                                              FontWeight.bold,
                                              color: Colors.white,
                                      
                                        ),
                                      ),
                                    ),

                                    DataColumn(
                                      label: Text(
                                        'Time',
                                        style: TextStyle(
                                          fontWeight:
                                              FontWeight.bold,
                                              color: Colors.white,
                                        ),
                                      ),
                                    ),

                                    DataColumn(
                                      label: Text(
                                        'Medication',
                                        style: TextStyle(
                                          fontWeight:
                                              FontWeight.bold,
                                              color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],

                                  rows: medications.map((medication) {

                                    final DateTime dateTime =
                                        DateTime.parse(
                                      medication[
                                          'dateAdministered'],
                                    );

                                    final String date =
                                        DateFormat(
                                          'd MMM yyyy',
                                        ).format(dateTime);

                                    final String time =
                                        DateFormat(
                                          'h:mm a',
                                        ).format(dateTime);

                                    return DataRow(
                                      cells: [

                                        DataCell(
                                          Text(date),
                                        ),

                                        DataCell(
                                          Text(time),
                                        ),

                                        DataCell(
                                          Text(
                                            medication[
                                                'medicationName'],
                                            style:
                                                const TextStyle(
                                              fontWeight:
                                                  FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // text under the last card
                      const Text(
                        'This report displays medication administered to your child by school staff.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}