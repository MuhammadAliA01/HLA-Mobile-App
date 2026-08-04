class StudentHealthLog {
  final String studentId;
  final String studentName;
  bool hasSymptoms;
  String notes;

  StudentHealthLog({
    required this.studentId,
    required this.studentName,
    this.hasSymptoms = false,
    this.notes = '',
  });
}