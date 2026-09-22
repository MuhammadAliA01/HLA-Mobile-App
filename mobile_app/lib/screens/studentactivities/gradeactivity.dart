import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GradeActivityScreen extends StatefulWidget {
  final int activityID;
  final String studentName;
  final String homeworkDescription;
  final int? currentGrade;

  const GradeActivityScreen({
    super.key,
    required this.activityID,
    required this.studentName,
    required this.homeworkDescription,
    this.currentGrade,
  });

  @override
  State<GradeActivityScreen> createState() =>
      _GradeActivityScreenState();
}

class _GradeActivityScreenState
    extends State<GradeActivityScreen> {

  int selectedGrade = 0;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    selectedGrade = widget.currentGrade ?? 0;
  }

  Future<void> saveGrade() async {
    if (selectedGrade < 1 || selectedGrade > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a rating from 1 to 5 stars.'),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final response = await http.put(
        Uri.parse(
          'http://localhost:7205/api/Activity/grade/${widget.activityID}',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'grade': selectedGrade,
        }),
      );

      print('GRADE STATUS: ${response.statusCode}');
      print('GRADE RESPONSE: ${response.body}');

      if (response.statusCode == 200) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Activity graded successfully!'),
          ),
        );

        Navigator.pop(context, true);
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to save grade: ${response.body}',
            ),
          ),
        );
      }
    } catch (e) {
      print('GRADE ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving grade: $e'),
        ),
      );
    }

    if (mounted) {
      setState(() {
        isSaving = false;
      });
    }
  }

  Widget buildStar(int starNumber) {
    final isSelected = starNumber <= selectedGrade;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGrade = starNumber;
        });
      },
      child: Icon(
        isSelected
            ? Icons.star
            : Icons.star_border,
        size: 55,
        color: Colors.amber,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grade Activity'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Text(
              widget.studentName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),

              child: Text(
                widget.homeworkDescription,
                style: const TextStyle(
                  fontSize: 17,
                ),
              ),
            ),

            const SizedBox(height: 35),

            const Center(
              child: Text(
                'Give a Rating',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 15),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,

              children: [
                buildStar(1),
                buildStar(2),
                buildStar(3),
                buildStar(4),
                buildStar(5),
              ],
            ),

            const SizedBox(height: 15),

            Center(
              child: Text(
                selectedGrade == 0
                    ? 'No rating selected'
                    : '$selectedGrade / 5',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 52,

              child: ElevatedButton(
                onPressed: isSaving
                    ? null
                    : saveGrade,

                child: isSaving
                    ? const CircularProgressIndicator()
                    : const Text(
                        'Save Grade',
                        style: TextStyle(
                          fontSize: 17,
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