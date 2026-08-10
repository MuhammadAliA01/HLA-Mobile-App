import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/screens/studentactivities/createactivity.dart';


class ActivityDashboard extends StatefulWidget {
  const ActivityDashboard({super.key});

  @override
  State<ActivityDashboard> createState() =>
      _ActivityDashboardState();
}

class _ActivityDashboardState extends State<ActivityDashboard> {
  final FlutterSecureStorage storage =
      const FlutterSecureStorage();

  List<dynamic> activities = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadActivities();
  }

  Future<void> loadActivities() async {
    try {
      final teacherID =
          await storage.read(key: 'staffId');

      if (teacherID == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse(
          'http://localhost:7205/api/Activity/teacher/$teacherID',
        ),
      );

      print('STATUS: ${response.statusCode}');
      print('BODY: ${response.body}');

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
      print('ERROR: $e');

      setState(() {
        isLoading = false;
      });
    }
  }

  Map<String, List<dynamic>> groupActivitiesByStudent() {
    Map<String, List<dynamic>> grouped = {};

    for (var activity in activities) {
      String studentName = activity['studentName'];

      if (!grouped.containsKey(studentName)) {
        grouped[studentName] = [];
      }

      grouped[studentName]!.add(activity);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final groupedActivities =
        groupActivitiesByStudent();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Activities'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,

        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Create Activity',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const CreateActivityScreen(),
                ),
              );

              // Refresh activities after returning
              loadActivities();
            },
          ),
        ],
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : groupedActivities.isEmpty
              ? const Center(
                  child: Text(
                    'No activities assigned yet.',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),

                  children: groupedActivities.entries
                      .map((entry) {

                    String studentName = entry.key;
                    List<dynamic> studentActivities =
                        entry.value;

                    return Card(
                      margin: const EdgeInsets.only(
                        bottom: 16,
                      ),

                      child: Padding(
                        padding: const EdgeInsets.all(16),

                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [

                            // STUDENT NAME
                            Row(
                              children: [

                                const CircleAvatar(
                                  child: Icon(
                                    Icons.person,
                                  ),
                                ),

                                const SizedBox(width: 12),

                                Text(
                                  studentName,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            const Divider(
                              height: 24,
                            ),

                            // ACTIVITIES
                            ...studentActivities
                                .map((activity) {

                              return Container(
                                width: double.infinity,
                                margin:
                                    const EdgeInsets.only(
                                  bottom: 10,
                                ),

                                padding:
                                    const EdgeInsets.all(12),

                                decoration:
                                    BoxDecoration(
                                  color:
                                      Colors.grey.shade100,
                                  borderRadius:
                                      BorderRadius.circular(
                                    8,
                                  ),
                                ),

                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,

                                  children: [

                                    const Icon(
                                      Icons.assignment,
                                      color: Colors.blue,
                                    ),

                                    const SizedBox(
                                      width: 10,
                                    ),

                                    Expanded(
                                      child: Text(
                                        activity[
                                            'homeworkDescription'],
                                        style:
                                            const TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  })
                      .toList(),
                ),
    );
  }
}