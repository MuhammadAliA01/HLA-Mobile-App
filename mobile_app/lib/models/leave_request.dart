import 'dart:convert';
import 'package:http/http.dart' as http;

// Enums updated to match your strict C# database rules
enum LeaveRequestStatus {
  pendingHODReview,
  approved,
  rejected,
  cancelledByTeacher
}

enum LeaveType {
  sickLeave,
  familyResponsibility,
  studyLeave,
  annualLeave
}

class LeaveRequest {
  final String id;
  final String staffId;
  final LeaveType type;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;

  LeaveRequestStatus _status;
  LeaveRequestStatus get status => _status;

  LeaveRequest._({
    required this.id,
    required this.staffId,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required LeaveRequestStatus status,
  }) : _status = status;

  // Changed to static Future so it can await the C# server response
  static Future<LeaveRequest> submit({
    required String staffId,
    required LeaveType type,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (startDate.isBefore(today)) {
      throw ArgumentError('Leave cannot be requested for dates in the past.');
    }
    if (endDate.isBefore(startDate)) {
      throw ArgumentError('End date must be after start date.');
    }

    // 1. Send the data to your C# backend
    // REMEMBER: Update '7000' to your actual Visual Studio port!
    final url = Uri.parse('https://10.0.2.2:62691/api/leaverequest/submit');
    
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'staffId': int.parse(staffId),
        'type': type.index,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'reason': reason,
      }),
    );

    // If C# throws a BadRequest (like our date errors), this catches it
    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['error'] ?? 'Failed to submit to server.');
    }

    // 2. If the server says OK, return the local object so the UI can display it
    return LeaveRequest._(
      id: DateTime.now().millisecondsSinceEpoch.toString(), 
      staffId: staffId,
      type: type,
      startDate: startDate,
      endDate: endDate,
      reason: reason,
      status: LeaveRequestStatus.pendingHODReview, 
    );
  }

  // TASK 2: Approve
  void approve() {
    if (_status != LeaveRequestStatus.pendingHODReview) {
      throw StateError('Only pending requests can be approved.');
    }
    _status = LeaveRequestStatus.approved;
  }

  // TASK 3: Reject
  void reject() {
    if (_status != LeaveRequestStatus.pendingHODReview) {
      throw StateError('Only pending requests can be rejected.');
    }
    _status = LeaveRequestStatus.rejected;
  }
}  