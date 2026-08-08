
import 'package:flutter/material.dart';

void main() {
  runApp(const HomeworkGraderApp());
}

class HomeworkGraderApp extends StatelessWidget {
  const HomeworkGraderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Homework Grader',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const  DashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Data Model to represent a student activity
class StudentActivity {
  final String studentName;
  final String submissionText;
  double? mark;
  bool isGraded;

  StudentActivity({
    required this.studentName,
    required this.submissionText,
    this.mark,
    this.isGraded = false,
  });
}



// --- 2 & 3. DASHBOARD & SPECIFICATION SELECTION ---
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String selectedGrade = 'Grade 4';
  String selectedSubject = 'Language Dev';

  final List<String> grades = ['Grade 1', 'Grade 2', 'Grade 3','Grade 4','Grade 5','Grade 6','Grade 7'];
  final List<String> subjects = ['Language Dev', 'Creative Dev', 'Gaining Indp','Basic Concepts','Physical Therapy','Social Skills'];

  // Global mock storage for active tasks
  List<StudentActivity> activeSubmissions = [
    StudentActivity(studentName: 'Alice Smith', submissionText: 'Fraction assignment answers doc.'),
    StudentActivity(studentName: 'Bob Jones', submissionText: 'Completed geometry problem sheet.'),
  ];

  String? currentUploadedActivity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assessments'),
        backgroundColor: Colors.blue.shade100,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Your Assignment Targeting:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedGrade,
                    decoration: const InputDecoration(labelText: 'Grade', border: OutlineInputBorder()),
                    items: grades.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                    onChanged: (val) => setState(() => selectedGrade = val!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedSubject,
                    decoration: const InputDecoration(labelText: 'Subject', border: OutlineInputBorder()),
                    items: subjects.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (val) => setState(() => selectedSubject = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),
            
            // --- 4 & 5. UPLOAD & DISTRIBUTION ACTION ---
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Current Week Activity for $selectedSubject ($selectedGrade)', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(currentUploadedActivity == null 
                        ? 'No activity distributed yet.' 
                        : 'Active: $currentUploadedActivity'),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload & Send Homework to Dashboard'),
                      onPressed: () async {
                        // Simulate selecting a file activity
                        setState(() {
                          currentUploadedActivity = 'Weekly_Activity_Pack_${selectedSubject.substring(0,3)}.pdf';
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('System distributed homework to all students successfully!'))
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Pending Homework Submissions (To Grade)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            
            // --- 6 & 7. VIEW SUBMISSIONS & DYNAMIC GRADING LIST ---
            Expanded(
              child: ListView.builder(
                itemCount: activeSubmissions.length,
                itemBuilder: (context, index) {
                  final item = activeSubmissions[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text(item.studentName),
                      subtitle: Text(item.isGraded ? 'Status: Graded | Mark: ${item.mark}%' : 'Status: Pending Grading'),
                      trailing: Icon(item.isGraded ? Icons.check_circle : Icons.pending, color: item.isGraded ? Colors.green : Colors.orange),
                      onTap: () async {
                        // Navigate to Grading panel
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GradingScreen(studentActivity: item),
                          ),
                        );
                        if (result != null && result is StudentActivity) {
                          setState(() {
                            activeSubmissions[index] = result;
                          });
                        }
                      },
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class GradingScreen extends StatefulWidget {
  final StudentActivity studentActivity;
  const GradingScreen({super.key, required this.studentActivity});

  @override
  State<GradingScreen> createState() => _GradingScreenState();
}

class _GradingScreenState extends State<GradingScreen> {
  final _markController = TextEditingController();
  final _criteriaController = TextEditingController(text: 'Met assignment core criteria definitions.');

  @override
  void initState() {
    super.initState();
    if (widget.studentActivity.mark != null) {
      _markController.text = widget.studentActivity.mark!.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Grade: ${widget.studentActivity.studentName}')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Submission Payload:', style: Theme.of(context).textTheme.titleMedium),
            Text(widget.studentActivity.submissionText, style: const TextStyle(fontSize: 15, color: Colors.grey)),
            const SizedBox(height: 24),
            TextField(
              controller: _criteriaController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Criteria Notes', border: OutlineInputBorder()),),const SizedBox(height: 16),TextField(controller: _markController,keyboardType: TextInputType.number,decoration: const InputDecoration(labelText: 'Assign Mark (%)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.percent)),),const SizedBox(height: 32),ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.all(16)),onPressed: () {double? finalMark = double.tryParse(_markController.text);if (finalMark != null) {widget.studentActivity.mark = finalMark;widget.studentActivity.isGraded = true;Navigator.pop(context, widget.studentActivity);ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('System updated student marks successfully.')));}},child: const Text('Confirm Grade & Update Marks'),),],),),);}}