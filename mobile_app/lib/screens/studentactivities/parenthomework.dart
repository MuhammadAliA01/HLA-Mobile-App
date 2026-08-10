import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ParentHomeworkScreen extends StatefulWidget {
  const ParentHomeworkScreen({super.key});

  @override
  State<ParentHomeworkScreen> createState() =>
      _ParentHomeworkScreenState();
}

class _ParentHomeworkScreenState
    extends State<ParentHomeworkScreen> {

  final FlutterSecureStorage storage =
      const FlutterSecureStorage();

  List<dynamic> activities = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadHomework();
  }

  Future<void> loadHomework() async {
    try {
      final parentID =
          await storage.read(key: 'staffId');

      if (parentID == null) {
        setState(() {
          isLoading = false;
        });

        return;
      }

      final response = await http.get(
        Uri.parse(
          'http://192.168.0.159:7205/api/Activity/parent/$parentID',
        ),
      );

      print('STATUS CODE: ${response.statusCode}');
      print('RESPONSE BODY: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          activities = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading homework: $e');

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Homework'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : activities.isEmpty
              ? const Center(
                  child: Text(
                    'No homework assigned.',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    final activity =
                        activities[index];

                    return Card(
                      margin: const EdgeInsets.only(
                        bottom: 12,
                      ),

                      child: Padding(
                        padding: const EdgeInsets.all(16),

                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [

                            Text(
                              'Homework',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                            ),

                            const SizedBox(height: 10),

                            Text(
                              activity[
                                  'homeworkDescription'],
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Text(
                              'Student ID: ${activity['studentID']}',
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}