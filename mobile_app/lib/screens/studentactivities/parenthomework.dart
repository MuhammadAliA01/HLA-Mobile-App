import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;


class ParentHomeworkScreen
    extends StatefulWidget {

  const ParentHomeworkScreen({
    super.key,
  });


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


  // ============================================================
  // LOAD HOMEWORK
  // ============================================================

  Future<void> loadHomework() async {

    try {

      final parentID =
          await storage.read(
        key: 'staffId',
      );


      if (parentID == null) {

        setState(() {
          isLoading = false;
        });

        return;
      }


      final response = await http.get(

        Uri.parse(
          'http://localhost:7205/api/Activity/parent/$parentID',
        ),
      );


      print(
        'STATUS CODE: ${response.statusCode}',
      );

      print(
        'RESPONSE BODY: ${response.body}',
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
        'Error loading homework: $e',
      );


      setState(() {
        isLoading = false;
      });
    }
  }


  // ============================================================
  // STAR DISPLAY
  // ============================================================

  Widget buildRating(dynamic grade) {

    if (grade == null) {

      return const Row(

        children: [

          Icon(
            Icons.star_border,
            color: Colors.grey,
            size: 22,
          ),

          SizedBox(
            width: 8,
          ),

          Text(
            'Not graded yet',

            style: TextStyle(
              color: Colors.grey,
              fontSize: 15,
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

            color:
                Colors.amber,

            size:
                25,
          ),
        ),


        const SizedBox(
          width: 8,
        ),


        Text(

          '$grade/5',

          style:
              const TextStyle(
            fontSize: 16,
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

    return Scaffold(

      appBar: AppBar(

        title:
            const Text(
          'Homework',
        ),

        backgroundColor:
            const Color.fromARGB(255, 241, 182, 105),

        foregroundColor:
            Colors.white,
      ),


      body:

          isLoading

              ? const Center(
                  child:
                      CircularProgressIndicator(),
                )


              : activities.isEmpty

                  ? const Center(

                      child: Text(

                        'No homework assigned.',

                        style:
                            TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    )


                  : ListView.builder(

                      padding:
                          const EdgeInsets.all(
                        16,
                      ),

                      itemCount:
                          activities.length,


                      itemBuilder:
                          (context, index) {

                        final activity =
                            activities[index];


                        return Card(

                          margin:
                              const EdgeInsets.only(
                            bottom: 12,
                          ),


                          child:
                              Padding(

                            padding:
                                const EdgeInsets.all(
                              16,
                            ),


                            child:
                                Column(

                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [

                                // ==================================
                                // STUDENT NAME
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
                                      width: 10,
                                    ),


                                    Expanded(

                                      child:
                                          Text(

                                        activity[
                                            'studentName'],

                                        style:
                                            const TextStyle(
                                          fontSize:
                                              19,
                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),


                                const SizedBox(
                                  height: 15,
                                ),


                                const Divider(),


                                const SizedBox(
                                  height: 10,
                                ),


                                // ==================================
                                // HOMEWORK
                                // ==================================

                                const Text(

                                  'Homework',

                                  style:
                                      TextStyle(
                                    fontSize:
                                        17,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),


                                const SizedBox(
                                  height: 8,
                                ),


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
                                  height: 18,
                                ),


                                // ==================================
                                // GRADE
                                // ==================================

                                const Text(

                                  'Teacher Rating',

                                  style:
                                      TextStyle(
                                    fontSize:
                                        15,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),


                                const SizedBox(
                                  height: 7,
                                ),


                                buildRating(
                                  activity[
                                      'grade'],
                                ),


                                // ==================================
                                // GRADED DATE
                                // ==================================

                                if (activity[
                                        'gradedAt'] !=
                                    null) ...[

                                  const SizedBox(
                                    height: 8,
                                  ),


                                  Text(

                                    'Graded: ${activity['gradedAt']}',

                                    style:
                                        const TextStyle(
                                      fontSize:
                                          12,
                                      color:
                                          Colors.grey,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}