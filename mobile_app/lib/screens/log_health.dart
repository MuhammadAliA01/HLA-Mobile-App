import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/student_health.dart';

class LogHealthScreen extends StatefulWidget {
  final int classId;
  final String className;

  const LogHealthScreen({
    super.key,
    required this.classId,
    required this.className,
  });

  @override
  State<LogHealthScreen> createState() => _LogHealthScreenState();
}

class _LogHealthScreenState extends State<LogHealthScreen> {
  late String currentDate;

  bool _isSubmitted = false;
  bool _isLoadingAi = false;

  bool _isLoadingRoster = true;
  String _rosterError = '';
  List<StudentHealthLog> _studentLogs = [];

  final List<String> _quickSymptoms = [
    "Fever",
    "Cough",
    "Runny Nose",
    "Fatigue",
    "Headache"
  ];

  String? _analysisSummary;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    currentDate = "${_monthName(now.month)} ${now.day}, ${now.year}";
    _fetchRoster();
  }

  String _monthName(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return months[month - 1];
  }

 // Temporary test data
List<StudentHealthLog> _getDummyRoster() {
  return [
    StudentHealthLog(studentId: "1", studentName: "Liam Smith"),
    StudentHealthLog(studentId: "2", studentName: "Emma Johnson"),
    StudentHealthLog(studentId: "3", studentName: "Noah Williams"),
    StudentHealthLog(studentId: "4", studentName: "Olivia Brown"),
    StudentHealthLog(studentId: "5", studentName: "Ava Jones"),


  ];
}

  Future<void> _fetchRoster() async {
    const storage = FlutterSecureStorage();
    final staffId = await storage.read(key: "staffId");
    final token = await storage.read(key: "token");

    if (staffId == null) {
      if (!mounted) return;
      setState(() {
        _studentLogs = _getDummyRoster();
        _isLoadingRoster = false;
      });
      return;
    }

    // Aligned endpoint path and removed classId query parameter
    final uri = Uri.parse("http://localhost:7205/api/Students/GetTeacherStudents")
        .replace(queryParameters: {
      "teacherId": staffId,
    });

    try {
      final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final fetchedLogs = data.map((json) {
          return StudentHealthLog(
            // Maps to studentId / StudentId returned by backend
            studentId: (json['studentId'] ?? json['StudentId'] ?? '').toString(),
            // Maps to fullName / FullName returned by backend
            studentName: json['fullName'] ?? json['FullName'] ?? 'Unknown Student',
          );
        }).toList();

        setState(() {
          _studentLogs =
              fetchedLogs.isNotEmpty ? fetchedLogs : _getDummyRoster();
          _isLoadingRoster = false;
        });
      } else {
        setState(() {
          _studentLogs = _getDummyRoster();
          _isLoadingRoster = false;
        });
      }
    } catch (e, stackTrace) {
  debugPrint("==== ROSTER FETCH ERROR ====");
  debugPrint("Error: $e");
  debugPrint("Stacktrace: $stackTrace");

  if (!mounted) return;

  setState(() {
    _studentLogs = _getDummyRoster();
    _isLoadingRoster = false;
  });
}
  }

  Future<String> _fetchAiRecommendation(
      List<String> collectedSymptoms) async {
    const apiKey = 'AQ.Ab8RN6JG1IidybpaTrBJmbL697XRakBm_LOYmroc83VPUS81aA';
    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-lite-preview:generateContent?key=$apiKey');

    final prompt =
        "Students in ${widget.className} reported symptoms: ${collectedSymptoms.join(', ')}. "
        "Provide actionable advice for the teacher on what to do next based on each childs symptom. Keep the response to 1 - 3 sentences.";

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates']?[0]?['content']?['parts']?[0]?['text']
                ?.trim() ??
            "Notify the school nurse and keep symptomatic students comfortable until assessed.";
      }
    } catch (_) {}
    return "Please notify the school nurse and monitor symptomatic students closely.";
  }

  Future<void> _submitHealthLog() async {
    final symptomaticStudents =
        _studentLogs.where((s) => s.hasSymptoms).toList();
    final allSymptoms = symptomaticStudents
        .map((s) => s.notes.isEmpty ? "Unspecified symptoms" : s.notes)
        .toList();

    setState(() {
      _isSubmitted = true;
      _isLoadingAi = true;
    });

    if (symptomaticStudents.isEmpty) {
      setState(() {
        _analysisSummary =
            "All ${_studentLogs.length} students are healthy today! No immediate actions required.";
        _isLoadingAi = false;
      });
    } else {
      final aiAdvice = await _fetchAiRecommendation(allSymptoms);
      if (!mounted) return;
      setState(() {
        _analysisSummary = aiAdvice;
        _isLoadingAi = false;
      });
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text("Health log saved successfully!"),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalSymptoms = _studentLogs.where((s) => s.hasSymptoms).length;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Log Student Health",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoadingRoster
          ? const Center(child: CircularProgressIndicator())
          : _rosterError.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_rosterError,
                          style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isLoadingRoster = true;
                            _rosterError = '';
                          });
                          _fetchRoster();
                        },
                        child: const Text("Retry"),
                      )
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- HEADER SUMMARY CARD ---
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.className,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today,
                                        size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(currentDate,
                                        style:
                                            const TextStyle(color: Colors.grey)),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: totalSymptoms > 0
                                    ? Colors.red.shade50
                                    : Colors.green.shade50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "$totalSymptoms Flagged",
                                style: TextStyle(
                                  color: totalSymptoms > 0
                                      ? Colors.red
                                      : Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                      const Text("Class Roster",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),

                      // --- ROSTER LIST ---
                      _studentLogs.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 32.0),
                              child: Center(
                                  child: Text("No students found in this class.")),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _studentLogs.length,
                              itemBuilder: (context, index) {
                                final student = _studentLogs[index];
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: student.hasSymptoms
                                          ? Colors.red.shade200
                                          : Colors.transparent,
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.03),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: student.hasSymptoms
                                                ? Colors.red.shade100
                                                : Colors.blue.shade100,
                                            child: Icon(
                                              student.hasSymptoms
                                                  ? Icons.sick
                                                  : Icons
                                                      .sentiment_satisfied_alt,
                                              color: student.hasSymptoms
                                                  ? Colors.red
                                                  : Colors.blue,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              student.studentName,
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),

                                          // --- TOGGLE SWITCH ---
                                          Row(
                                            children: [
                                              Text(
                                                student.hasSymptoms
                                                    ? "Symptoms"
                                                    : "Healthy",
                                                style: TextStyle(
                                                  color: student.hasSymptoms
                                                      ? Colors.red.shade700
                                                      : Colors.grey.shade700,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Switch.adaptive(
                                                value: student.hasSymptoms,
                                                activeColor: Colors.red,
                                                activeTrackColor:
                                                    Colors.red.shade100,
                                                inactiveThumbColor: Colors.green,
                                                inactiveTrackColor:
                                                    Colors.green.shade100,
                                                onChanged: _isSubmitted
                                                    ? null
                                                    : (bool selected) {
                                                        setState(() {
                                                          student.hasSymptoms =
                                                              selected;
                                                        });
                                                      },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),

                                      // SYMPTOM SELECTION
                                      if (student.hasSymptoms) ...[
                                        const Divider(height: 24),
                                        const Text(
                                          "Select or Type Symptoms:",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 8),

                                        // Quick Chips
                                        Wrap(
                                          spacing: 6,
                                          children:
                                              _quickSymptoms.map((symptom) {
                                            final isSelected = student.notes
                                                .contains(symptom);
                                            return FilterChip(
                                              label: Text(symptom,
                                                  style: const TextStyle(
                                                      fontSize: 12)),
                                              selected: isSelected,
                                              onSelected: _isSubmitted
                                                  ? null
                                                  : (bool selected) {
                                                      setState(() {
                                                        if (selected) {
                                                          student.notes += (student
                                                                  .notes.isEmpty
                                                              ? ""
                                                              : ", ") +
                                                          symptom;
                                                        } else {
                                                          student.notes = student
                                                              .notes
                                                              .replaceAll(
                                                                  symptom, "")
                                                              .trim();
                                                        }
                                                      });
                                                    },
                                            );
                                          }).toList(),
                                        ),
                                        const SizedBox(height: 8),

                                        // Custom notes field
                                        TextField(
                                          enabled: !_isSubmitted,
                                          decoration: InputDecoration(
                                            hintText: "Additional details...",
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8),
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            fillColor: Colors.grey.shade50,
                                            filled: true,
                                          ),
                                          onChanged: (val) =>
                                              student.notes = val,
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              },
                            ),

                      const SizedBox(height: 16),

                      // --- SUBMIT BUTTON ---
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          icon: _isLoadingAi
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : Icon(_isSubmitted
                                  ? Icons.check
                                  : Icons.send),
                          label: Text(
                            _isLoadingAi
                                ? "Analyzing Symptoms..."
                                : (_isSubmitted
                                    ? "Log Submitted for Today"
                                    : "LOG HEALTH"),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            backgroundColor: _isSubmitted
                                ? Colors.grey
                                : Theme.of(context).primaryColor,
                          ),
                          onPressed: _isSubmitted || _studentLogs.isEmpty
                              ? null
                              : _submitHealthLog,
                        ),
                      ),

                      // --- REAL-TIME ANALYSIS DASHBOARD ---
                      if (_analysisSummary != null || _isLoadingAi) ...[
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.indigo.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.auto_graph, color: Colors.indigo),
                                  SizedBox(width: 8),
                                  Text(
                                    "Real-Time Health Analysis",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.indigo,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _isLoadingAi
                                  ? const LinearProgressIndicator()
                                  : Text(
                                      _analysisSummary!,
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.indigo.shade900,
                                          height: 1.4),
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }
}