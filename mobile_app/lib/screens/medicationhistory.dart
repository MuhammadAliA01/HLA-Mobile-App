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

  @override
  void initState() {
    super.initState();
    getMedicationHistory();
  }

  Future<void> getMedicationHistory() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://192.168.0.159:7205/api/MedsAdministered/student/${widget.studentId}/history',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: medications.length,
                  itemBuilder: (context, index) {
                    final medication = medications[index];

                    final DateTime dateTime =
                        DateTime.parse(
                      medication['dateAdministered'],
                    );

                    final String date =
                        DateFormat('d MMMM yyyy')
                            .format(dateTime);

                    final String time =
                        DateFormat('h:mm a')
                            .format(dateTime);

                    return Card(
                      margin: const EdgeInsets.only(
                        bottom: 12,
                      ),

                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor:
                              Colors.deepOrange,
                          child: Icon(
                            Icons.medication,
                            color: Colors.white,
                          ),
                        ),

                        title: Text(
                          medication['medicationName'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        subtitle: Text(
                          '$date • $time',
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}