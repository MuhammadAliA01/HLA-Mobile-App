import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MedsTrackingPage());
  }
}

class MedsTrackingPage extends StatefulWidget {
  const MedsTrackingPage({super.key});

  @override
  State<MedsTrackingPage> createState() => _MedsTrackingPageState();
}

class _MedsTrackingPageState extends State<MedsTrackingPage> {
  // Holds the date and time selected by the teacher
  DateTime _administeredDateTime = DateTime.now();

  // Holds the medication selected from the dropdown
  String? _selectedMedication;

  // Hardcoded medication list for now
  final List<String> _medications = [
    'Ritalin 10mg',
    'Panado 500mg',
    'Allergex',
    'Stilpane',
  ];

  // Temporary mapping between medication names and database IDs
  final Map<String, int> _medicationIds = {
    'Ritalin 10mg': 1,
    'Panado 500mg': 2,
    'Allergex': 3,
    'Stilpane': 4,
  };

  // Sends the medication administration information to the backend
  // and gets the correct student's parent information back.
  Future<Map<String, dynamic>?> administerMedication() async {
    if (_selectedMedication == null) {
      return null;
    }

    // Get the database medication ID
    final int selectedMedId = _medicationIds[_selectedMedication]!;

    try {
      final response = await http.post(
        Uri.parse(
          'https://localhost:59074/api/MedsAdministered',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'studentID': 1, // hardcoded for now
          'teacherID': 1, // hardcoded for now
          'medID': selectedMedId,
          'dateAdministered':
              _administeredDateTime.toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        // Convert the backend response from JSON
        final Map<String, dynamic> data =
            jsonDecode(response.body);

        debugPrint(
          'Medication recorded successfully',
        );

        // Print the full backend response
        debugPrint(
          'Backend response: ${response.body}',
        );

        // Get the parent information returned by the backend
        final parent = data['parent'];

        if (parent != null) {
          debugPrint(
            'Parent ID: ${parent['parentId']}',
          );

          debugPrint(
            'Parent Name: '
            '${parent['firstName']} '
            '${parent['surname']}',
          );

          debugPrint(
            'Parent Email: ${parent['email']}',
          );
        }

        // Return the parent information
        return parent;
      } else {
        debugPrint(
          'Something went wrong',
        );

        debugPrint(
          'Status code: ${response.statusCode}',
        );

        debugPrint(
          'Response: ${response.body}',
        );

        return null;
      }
    } catch (e) {
      debugPrint(
        'Error connecting to backend: $e',
      );

      return null;
    }
  }

  // Date picker
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _administeredDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _administeredDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _administeredDateTime.hour,
          _administeredDateTime.minute,
        );
      });
    }
  }

  // Time picker
  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime:
          TimeOfDay.fromDateTime(_administeredDateTime),
    );

    if (picked != null) {
      setState(() {
        _administeredDateTime = DateTime(
          _administeredDateTime.year,
          _administeredDateTime.month,
          _administeredDateTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String formattedTime =
        DateFormat('h:mm a')
            .format(_administeredDateTime);

    final String formattedDate =
        DateFormat('d MMMM yyyy')
            .format(_administeredDateTime);

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            const Color.fromARGB(255, 239, 123, 87),
        title:
            const Text('Medication Tracking'),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [

            // First Card - Student Information
            Card(
              margin:
                  const EdgeInsets.all(25),

              child: SizedBox(
                width: double.infinity,
                height: 200,

                child: Padding(
                  padding:
                      const EdgeInsets.all(20),

                  child: Row(
                    children: [

                      const Icon(
                        Icons.person,
                        size: 70,
                        color:
                            Colors.deepOrange,
                      ),

                      const SizedBox(
                        width: 20,
                      ),

                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        mainAxisAlignment:
                            MainAxisAlignment.center,

                        children: const [

                          Text(
                            'Azraa Khan',
                            style:
                                TextStyle(
                              fontSize: 26,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          SizedBox(
                            height: 10,
                          ),

                          Text(
                            'Grade 2',
                          ),

                          SizedBox(
                            height: 10,
                          ),

                          Text(
                            'Student no: 223456',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Second Card - Meds Info
            Card(
              margin:
                  const EdgeInsets.all(25),

              child: SizedBox(
                width: double.infinity,
                height: 200,

                child: Padding(
                  padding:
                      const EdgeInsets.all(20),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      const Text(
                        'Medication',
                        style:
                            TextStyle(
                          fontSize: 20,
                          color:
                              Colors.deepOrange,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      // Dropdown for meds
                      DropdownButtonFormField<String>(
                        initialValue:
                            _selectedMedication,

                        decoration:
                            InputDecoration(
                          hintText:
                              'Select medication',

                          prefixIcon:
                              const Icon(
                            Icons.medication,
                            size: 30,
                            color:
                                Colors.deepOrange,
                          ),

                          border:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(
                                    10),
                          ),
                        ),

                        items:
                            _medications.map(
                          (String medication) {
                            return DropdownMenuItem<
                                String>(
                              value:
                                  medication,

                              child: Text(
                                medication,
                                style:
                                    const TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            );
                          },
                        ).toList(),

                        onChanged:
                            (String? newValue) {
                          setState(() {
                            _selectedMedication =
                                newValue;
                          });
                        },
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      // Shows the selected medication
                      if (_selectedMedication !=
                          null)
                        Row(
                          children: [

                            const Icon(
                              Icons.medication,
                              size: 30,
                              color:
                                  Colors.deepOrange,
                            ),

                            const SizedBox(
                              width: 15,
                            ),

                            Text(
                              _selectedMedication!,
                              style:
                                  const TextStyle(
                                fontSize: 22,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Third Card - Log Administration
            Card(
              margin:
                  const EdgeInsets.all(25),

              child: Padding(
                padding:
                    const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    const Text(
                      'Log Administration',
                      style:
                          TextStyle(
                        fontSize: 24,
                        color:
                            Colors.deepOrange,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    // Actual Time
                    InkWell(
                      onTap:
                          _pickTime,

                      borderRadius:
                          BorderRadius.circular(
                              10),

                      child: Row(
                        children: [

                          const Icon(
                            Icons.access_time,
                            size: 30,
                            color:
                                Colors.deepOrange,
                          ),

                          const SizedBox(
                            width: 15,
                          ),

                          const Text(
                            'Actual Time',
                            style:
                                TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const Spacer(),

                          Text(
                            formattedTime,
                            style:
                                const TextStyle(
                              fontSize: 18,
                            ),
                          ),

                          const SizedBox(
                            width: 6,
                          ),

                          const Icon(
                            Icons.edit,
                            size: 18,
                            color:
                                Colors.grey,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 25,
                    ),

                    // Date
                    InkWell(
                      onTap:
                          _pickDate,

                      borderRadius:
                          BorderRadius.circular(
                              10),

                      child: Row(
                        children: [

                          const Icon(
                            Icons.calendar_month,
                            size: 30,
                            color:
                                Colors.deepOrange,
                          ),

                          const SizedBox(
                            width: 15,
                          ),

                          const Text(
                            'Date',
                            style:
                                TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const Spacer(),

                          Text(
                            formattedDate,
                            style:
                                const TextStyle(
                              fontSize: 18,
                            ),
                          ),

                          const SizedBox(
                            width: 6,
                          ),

                          const Icon(
                            Icons.edit,
                            size: 18,
                            color:
                                Colors.grey,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 25,
                    ),

                    const Text(
                      'Notes (optional)',
                      style:
                          TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    TextField(
                      decoration:
                          InputDecoration(
                        hintText:
                            'Add a note...',

                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(
                                  10),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 25,
                    ),

                    // Confirmation Button
                    SizedBox(
                      width:
                          double.infinity,
                      height: 55,

                      child:
                          ElevatedButton.icon(

                        onPressed:
                            () async {

                          // Check that a medication
                          // has been selected
                          if (_selectedMedication ==
                              null) {

                            ScaffoldMessenger.of(
                                    context)
                                .showSnackBar(
                              const SnackBar(
                                content:
                                    Text(
                                  'Please select a medication first.',
                                ),
                              ),
                            );

                            return;
                          }

                          // Send information to backend
                          // and get parent information
                          final parent =
                              await administerMedication();

                          if (parent != null &&
                              mounted) {

                            // Print parent details
                            debugPrint(
                              'Correct parent found:',
                            );

                            debugPrint(
                              'Parent ID: '
                              '${parent['parentId']}',
                            );

                            debugPrint(
                              'Parent Name: '
                              '${parent['firstName']} '
                              '${parent['surname']}',
                            );

                            debugPrint(
                              'Parent Email: '
                              '${parent['email']}',
                            );

                            Navigator.push(
                              context,

                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        ConfirmationScreen(
                                  studentName:
                                      'Azraa Khan',

                                  administeredDateTime:
                                      _administeredDateTime,
                                ),
                              ),
                            );

                          } else if (mounted) {

                            ScaffoldMessenger.of(
                                    context)
                                .showSnackBar(
                              const SnackBar(
                                content:
                                    Text(
                                  'Medication could not be recorded.',
                                ),
                              ),
                            );
                          }
                        },

                        icon:
                            const Icon(
                          Icons.check_circle,
                        ),

                        label:
                            const Text(
                          'Confirm Administered',
                          style:
                              TextStyle(
                            fontSize: 18,
                          ),
                        ),

                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.deepOrange,

                          foregroundColor:
                              Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    // Overdue Notice
                    Container(
                      width:
                          double.infinity,

                      padding:
                          const EdgeInsets.all(
                              16),

                      decoration:
                          BoxDecoration(
                        color:
                            Colors.orange.shade50,

                        borderRadius:
                            BorderRadius.circular(
                                10),

                        border:
                            Border.all(
                          color:
                              Colors.orange.shade200,
                        ),
                      ),

                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: [

                          Icon(
                            Icons.notifications,
                            color:
                                Colors.orange
                                    .shade700,
                          ),

                          const SizedBox(
                            width: 12,
                          ),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [

                                Text(
                                  'Medication Overdue',

                                  style:
                                      TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                    color:
                                        Colors.orange
                                            .shade700,
                                  ),
                                ),

                                const SizedBox(
                                  height: 6,
                                ),

                                RichText(
                                  text:
                                      TextSpan(

                                    style:
                                        const TextStyle(
                                      fontSize: 14,
                                      color:
                                          Colors.black87,
                                    ),

                                    children: [

                                      const TextSpan(
                                        text:
                                            'If medication is not logged within ',
                                      ),

                                      const TextSpan(
                                        text:
                                            '10 minutes',
                                        style:
                                            TextStyle(
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                      ),

                                      const TextSpan(
                                        text:
                                            ' of the scheduled time, the parent and principal will be notified.',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// Confirmation Screen
class ConfirmationScreen
    extends StatelessWidget {

  final String studentName;

  final DateTime administeredDateTime;

  const ConfirmationScreen({
    super.key,
    required this.studentName,
    required this.administeredDateTime,
  });

  @override
  Widget build(
      BuildContext context) {

    final String formattedTime =
        DateFormat('h:mm a')
            .format(administeredDateTime);

    final String formattedDate =
        DateFormat('d MMMM yyyy')
            .format(administeredDateTime);

    return Scaffold(

      appBar:
          AppBar(
        backgroundColor:
            const Color.fromARGB(
                255, 239, 123, 87),

        title:
            const Text(
                'Confirmation'),

        centerTitle:
            true,
      ),

      body:
          Center(

        child:
            Padding(
          padding:
              const EdgeInsets.all(
                  30),

          child:
              Column(

            mainAxisAlignment:
                MainAxisAlignment
                    .center,

            children: [

              const Icon(
                Icons.check_circle,
                size: 90,
                color:
                    Colors.green,
              ),

              const SizedBox(
                height: 20,
              ),

              const Text(
                'Medication Administered',

                style:
                    TextStyle(
                  fontSize: 24,
                  fontWeight:
                      FontWeight.bold,
                ),

                textAlign:
                    TextAlign.center,
              ),

              const SizedBox(
                height: 10,
              ),

              Text(
                "$studentName's medication has been administered",

                style:
                    const TextStyle(
                  fontSize: 16,
                ),

                textAlign:
                    TextAlign.center,
              ),

              const SizedBox(
                height: 15,
              ),

              Text(
                'Logged for $formattedTime on $formattedDate',

                style:
                    const TextStyle(
                  fontSize: 16,
                  color:
                      Colors.grey,
                ),

                textAlign:
                    TextAlign.center,
              ),

              const SizedBox(
                height: 20,
              ),

              // Notification indicator
              Container(

                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),

                decoration:
                    BoxDecoration(

                  color:
                      Colors.green.shade50,

                  borderRadius:
                      BorderRadius.circular(
                          10),

                  border:
                      Border.all(
                    color:
                        Colors.green.shade200,
                  ),
                ),

                child:
                    Row(

                  mainAxisSize:
                      MainAxisSize.min,

                  children: [

                    Icon(
                      Icons
                          .notifications_active,
                      size: 18,
                      color:
                          Colors.green
                              .shade700,
                    ),

                    const SizedBox(
                      width: 8,
                    ),

                    Text(
                      'Parent has been notified',

                      style:
                          TextStyle(
                        fontSize: 14,
                        color:
                            Colors.green
                                .shade700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 30,
              ),

              SizedBox(

                width:
                    double.infinity,

                height:
                    50,

                child:
                    ElevatedButton(

                  onPressed: () {

                    Navigator.pop(
                        context);

                  },

                  style:
                      ElevatedButton.styleFrom(

                    backgroundColor:
                        Colors.deepOrange,

                    foregroundColor:
                        Colors.white,
                  ),

                  child:
                      const Text(

                    'Back to Meds Tracking',

                    style:
                        TextStyle(
                      fontSize: 16,
                    ),
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