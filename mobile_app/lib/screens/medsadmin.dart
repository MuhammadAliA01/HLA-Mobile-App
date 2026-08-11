import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'meds_qr_scanner.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  runApp(MyApp());
}


class AppColors {
  static const Color primary = Color.fromARGB(255, 248, 75, 1); // muted terracotta
  static const Color primaryLight = Color(0xFFF3E3DA);
  static const Color primaryDark = Color(0xFF8F3F1E);

  static const Color background = Color(0xFFFAF7F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE8E2DD);

  static const Color textPrimary = Color(0xFF2C2A28);
  static const Color textSecondary = Color(0xFF6F6862);
  static const Color textMuted = Color(0xFF9B948D);

  static const Color success = Color(0xFF3F8F5C);
  static const Color successLight = Color(0xFFE5F3EA);

  static const Color warning = Color(0xFFC17A1F);
  static const Color warningLight = Color(0xFFFBF0DF);
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.surface,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

/// Small reusable avatar used for a student's initials, replacing the
/// large bare Icon(Icons.person) used previously.
class InitialsAvatar extends StatelessWidget {
  final String name;
  final double size;

  const InitialsAvatar({super.key, required this.name, this.size = 48});

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    final first = parts.first[0];
    final last =
        parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.primaryLight,
        shape: BoxShape.circle,
      ),
      child: Text(
        _initials,
        style: TextStyle(
          color: AppColors.primaryDark,
          fontWeight: FontWeight.w600,
          fontSize: size * 0.36,
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light,
      home: MedsTrackingPage(studentId: 1),
    );
  }
}

class MedsTrackingPage extends StatefulWidget {
  final int studentId;

  const MedsTrackingPage({
    super.key,
    required this.studentId,
  });

  @override
  State<MedsTrackingPage> createState() => _MedsTrackingPageState();
}

class _MedsTrackingPageState extends State<MedsTrackingPage> {
  final storage = const FlutterSecureStorage();
  // Holds date and time selected by the teacher
  DateTime _administeredDateTime = DateTime.now();

  // Holds medication selected from the dropdown
  String? _selectedMedication;
 

  @override
  void initState() {
    super.initState();
    getStudentDetails();
  }

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

  String studentName = '';
  String parentName = '';
  String className = '';

  Future<void> getStudentDetails() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://192.168.0.159:7205/api/MedsAdministered/students',
        ),
      );

      if (response.statusCode == 200) {
        final List students = jsonDecode(response.body);

        for (var student in students) {
          if (student['id'] == widget.studentId) {
            setState(() {
              studentName = student['name'];
              parentName = student['parentName'];
              className = student['className'];
            });

            break;
          }
        }
      }
    } catch (e) {
      debugPrint('Error getting student details: $e');
    }
  }

  
  Future<Map<String, dynamic>?> administerMedication() async {
    if (_selectedMedication == null) {
      return null;
    }

    // Get the database medication ID
    final int selectedMedId = _medicationIds[_selectedMedication]!;

    final String? staffId = await storage.read(key: "staffId");

if (staffId == null) {
  debugPrint('No logged-in staff ID found.');
  return null;
}

final int teacherId = int.parse(staffId);

    try {
      final response = await http.post(
        Uri.parse(
          'http://192.168.0.159:7205/api/MedsAdministered',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'studentID': widget.studentId,
          'teacherID': teacherId,
          'medID': selectedMedId,
          'dateAdministered': _administeredDateTime.toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        debugPrint('Medication recorded successfully');
        debugPrint('Backend response: ${response.body}');

        // Get the parent infoo returned by the backend and return it
        final parent = data['parent'];

        if (parent != null) {
          debugPrint('Parent ID: ${parent['parentId']}');
          debugPrint(
            'Parent Name: ${parent['firstName']} ${parent['surname']}',
          );
          debugPrint('Parent Email: ${parent['email']}');
        }

        return parent;
      } else {
        debugPrint('Something went wrong');
        debugPrint('Status code: ${response.statusCode}');
        debugPrint('Response: ${response.body}');

        return null;
      }
    } catch (e) {
      debugPrint('Error connecting to backend: $e');

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
      initialTime: TimeOfDay.fromDateTime(_administeredDateTime),
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
        DateFormat('h:mm a').format(_administeredDateTime);

    final String formattedDate =
        DateFormat('d MMMM yyyy').format(_administeredDateTime);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medication tracking'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Student info
Card(
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        InitialsAvatar(
          name: studentName,
          size: 56,
        ),

        const SizedBox(width: 16),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              studentName,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              'Parent: $parentName',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              'Class: $className',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    ),
  ),
),

            const SizedBox(height: 14),

            // Medication
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Medication',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedMedication,
                      icon: const Icon(Icons.keyboard_arrow_down,
                          color: AppColors.textMuted),
                      decoration: const InputDecoration(
                        hintText: 'Select medication',
                        prefixIcon: Icon(
                          Icons.medication_outlined,
                          color: AppColors.primary,
                        ),
                      ),
                      items: _medications.map((String medication) {
                        return DropdownMenuItem<String>(
                          value: medication,
                          child: Text(
                            medication,
                            style: const TextStyle(fontSize: 16),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedMedication = newValue;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Log administration
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Log administration',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _EditableRow(
                      icon: Icons.access_time,
                      label: 'Time',
                      value: formattedTime,
                      onTap: _pickTime,
                    ),
                    const SizedBox(height: 8),
                    _EditableRow(
                      icon: Icons.calendar_month_outlined,
                      label: 'Date',
                      value: formattedDate,
                      onTap: _pickDate,
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Notes (optional)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const TextField(
                      minLines: 2,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Add a note...',
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          
                          if (_selectedMedication == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Please select a medication first.'),
                              ),
                            );

                            return;
                          }

                         
                          final parent = await administerMedication();

                          if (parent != null && mounted) {
                            debugPrint('Correct parent found:');
                            debugPrint('Parent ID: ${parent['parentId']}');
                            debugPrint(
                              'Parent Name: ${parent['firstName']} ${parent['surname']}',
                            );
                            debugPrint('Parent Email: ${parent['email']}');

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ConfirmationScreen(
                                  studentName: studentName,
                                  administeredDateTime: _administeredDateTime,
                                ),
                              ),
                            );
                          } else if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Medication could not be recorded.'),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Confirm administered'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Overdue message
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.notifications_none,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Medication overdue',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.warning,
                          ),
                        ),
                        const SizedBox(height: 4),
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 13.5,
                              height: 1.4,
                              color: AppColors.textSecondary,
                            ),
                            children: [
                              TextSpan(
                                text:
                                    'If medication is not logged within ',
                              ),
                              TextSpan(
                                text: '10 minutes',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              TextSpan(
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
    );
  }
}


class _EditableRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _EditableRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.edit_outlined,
                size: 16,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Confirmation Screen
class ConfirmationScreen extends StatelessWidget {
  final String studentName;
  final DateTime administeredDateTime;

  const ConfirmationScreen({
    super.key,
    required this.studentName,
    required this.administeredDateTime,
  });

  @override
  Widget build(BuildContext context) {
    final String formattedTime =
        DateFormat('h:mm a').format(administeredDateTime);

    final String formattedDate =
        DateFormat('d MMMM yyyy').format(administeredDateTime);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmation'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: const BoxDecoration(
                  color: AppColors.successLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 42,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Medication administered',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                "$studentName's medication has been administered",
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Logged for $formattedTime on $formattedDate',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Notification indicator
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.notifications_active_outlined,
                      size: 16,
                      color: AppColors.success,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Parent has been notified',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text('Back to Student List'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}