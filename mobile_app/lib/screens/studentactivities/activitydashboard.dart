import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'package:mobile_app/screens/studentactivities/createactivity.dart';
import 'package:mobile_app/screens/studentactivities/gradeactivity.dart';


class ActivityDashboard extends StatefulWidget {

  const ActivityDashboard({
    super.key,
  });


  @override
  State<ActivityDashboard> createState() =>
      _ActivityDashboardState();
}


class _ActivityDashboardState
    extends State<ActivityDashboard> {

  final FlutterSecureStorage storage =
      const FlutterSecureStorage();


  List<dynamic> activities = [];


  bool isLoading = true;


  @override
  void initState() {

    super.initState();

    loadActivities();
  }


  // ============================================================
  // LOAD ACTIVITIES
  // ============================================================

  Future<void> loadActivities() async {

    setState(() {
      isLoading = true;
    });


    try {

      final teacherID =
          await storage.read(
        key: 'staffId',
      );


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


      print(
        'STATUS: ${response.statusCode}',
      );

      print(
        'BODY: ${response.body}',
      );


      if (response.statusCode == 200) {

        setState(() {

          activities =
              jsonDecode(response.body);

          isLoading = false;
        });

      } else {

        setState(() {
          isLoading = false;
        });
      }

    } catch (e) {

      print(
        'ERROR: $e',
      );


      setState(() {
        isLoading = false;
      });
    }
  }


  // ============================================================
  // GROUP BY STUDENT
  // ============================================================

  Map<String, List<dynamic>>
      groupActivitiesByStudent() {

    Map<String, List<dynamic>>
        grouped = {};


    for (var activity in activities) {

      String studentName =
          activity['studentName'];


      if (!grouped.containsKey(
          studentName)) {

        grouped[studentName] = [];
      }


      grouped[studentName]!
          .add(activity);
    }


    return grouped;
  }


  // ============================================================
  // OPEN GRADING PAGE
  // ============================================================

  Future<void> openGradePage(
      dynamic activity,
      String studentName) async {

    final result =
        await Navigator.push(

      context,

      MaterialPageRoute(

        builder: (context) =>
            GradeActivityScreen(

          activityID:
              activity['activityID'],

          studentName:
              studentName,

          homeworkDescription:
              activity[
                  'homeworkDescription'],

          currentGrade:
              activity['grade'],
        ),
      ),
    );


    // Refresh dashboard after grading
    if (result == true) {
      loadActivities();
    }
  }


  // ============================================================
  // BUILD STAR DISPLAY
  // ============================================================

  Widget buildRating(dynamic grade) {

    if (grade == null) {

      return const Row(

        children: [

          Icon(
            Icons.star_border,
            color: Colors.grey,
            size: 20,
          ),

          SizedBox(
            width: 5,
          ),

          Text(
            'Not graded yet',

            style: TextStyle(
              color: Colors.grey,
              fontWeight:
                  FontWeight.w500,
            ),
          ),
        ],
      );
    }


    return Row(

      children: [

        ...List.generate(

          5,

          (index) => Icon(

            index < grade
                ? Icons.star
                : Icons.star_border,

            size: 20,

            color:
                Colors.amber,
          ),
        ),


        const SizedBox(
          width: 8,
        ),


        Text(
          '$grade/5',

          style: const TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ],
    );
  }


  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {

    final groupedActivities =
        groupActivitiesByStudent();


    return Scaffold(

      appBar: AppBar(

        title:
            const Text(
          'My Activities',
        ),

        backgroundColor:
            const Color.fromARGB(255, 241, 182, 105),

        foregroundColor:
            Colors.white,


        actions: [

          IconButton(

            icon:
                const Icon(
              Icons.add,
            ),

            tooltip:
                'Create Activity',

            onPressed: () async {

              await Navigator.push(

                context,

                MaterialPageRoute(

                  builder: (context) =>
                      const CreateActivityScreen(),
                ),
              );


              loadActivities();
            },
          ),
        ],
      ),


      body:

          isLoading

              ? const Center(
                  child:
                      CircularProgressIndicator(),
                )


              : groupedActivities
                      .isEmpty

                  ? const Center(

                      child: Text(

                        'No activities assigned yet.',

                        style:
                            TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    )


                  : ListView(

                      padding:
                          const EdgeInsets.all(
                        16,
                      ),


                      children:

                          groupedActivities
                              .entries
                              .map(

                        (entry) {

                          String studentName =
                              entry.key;


                          List<dynamic>
                              studentActivities =
                                  entry.value;


                          return Card(

                            margin:
                                const EdgeInsets.only(
                              bottom: 16,
                            ),


                            child: Padding(

                              padding:
                                  const EdgeInsets.all(
                                16,
                              ),


                              child: Column(

                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,

                                children: [

                                  // ==================================
                                  // STUDENT HEADER
                                  // ==================================

                                  Row(

                                    children: [

                                      const CircleAvatar(

                                        child:
                                            Icon(
                                          Icons.person,
                                        ),
                                      ),


                                      const SizedBox(
                                        width: 12,
                                      ),


                                      Expanded(

                                        child:
                                            Text(

                                          studentName,

                                          style:
                                              const TextStyle(
                                            fontSize:
                                                20,
                                            fontWeight:
                                                FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),


                                  const Divider(
                                    height: 24,
                                  ),


                                  // ==================================
                                  // ACTIVITIES
                                  // ==================================

                                  ...studentActivities
                                      .map(

                                    (activity) {

                                      return GestureDetector(

                                        onTap: () {

                                          openGradePage(
                                            activity,
                                            studentName,
                                          );
                                        },


                                        child:
                                            Container(

                                          width:
                                              double.infinity,

                                          margin:
                                              const EdgeInsets.only(
                                            bottom: 10,
                                          ),

                                          padding:
                                              const EdgeInsets.all(
                                            12,
                                          ),

                                          decoration:
                                              BoxDecoration(

                                            color:
                                                Colors.grey.shade100,

                                            borderRadius:
                                                BorderRadius.circular(
                                              8,
                                            ),
                                          ),


                                          child:
                                              Row(

                                            crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,

                                            children: [

                                              const Icon(

                                                Icons.assignment,

                                                color:
                                                    Colors.blue,
                                              ),


                                              const SizedBox(
                                                width: 10,
                                              ),


                                              Expanded(

                                                child:
                                                    Column(

                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,

                                                  children: [

                                                    // Homework
                                                    Text(

                                                      activity[
                                                          'homeworkDescription'],

                                                      style:
                                                          const TextStyle(
                                                        fontSize:
                                                            16,
                                                      ),
                                                    ),


                                                    const SizedBox(
                                                      height: 8,
                                                    ),


                                                    // Rating
                                                    buildRating(
                                                      activity[
                                                          'grade'],
                                                    ),
                                                  ],
                                                ),
                                              ),


                                              const SizedBox(
                                                width: 5,
                                              ),


                                              const Icon(

                                                Icons
                                                    .chevron_right,

                                                color:
                                                    Colors.grey,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                              .toList(),
                    ),
    );
  }
}