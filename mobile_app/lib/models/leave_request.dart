// Enums for strict typing
enum LeaveRequestStatus {
  pendingPrincipalReview,
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

  // The underscore makes the status private. 
  // It can only be changed by the specific task methods below!
  LeaveRequestStatus _status;

  // A "getter" so the UI can read the status, but not overwrite it
  LeaveRequestStatus get status => _status;

  // Private constructor for internal use
  LeaveRequest._({
    required this.id,
    required this.staffId,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required LeaveRequestStatus status,
  }) : _status = status;

  // TASK 1: The "Submit" Workflow
  factory LeaveRequest.submit({
    required String staffId,
    required LeaveType type,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) {
    // Business Rules Validation
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (startDate.isBefore(today)) {
      throw ArgumentError('Leave cannot be requested for dates in the past.');
    }
    if (endDate.isBefore(startDate)) {
      throw ArgumentError('End date must be after start date.');
    }

    return LeaveRequest._(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Temporary local ID
      staffId: staffId,
      type: type,
      startDate: startDate,
      endDate: endDate,
      reason: reason,
      status: LeaveRequestStatus.pendingPrincipalReview, // Forced initial state
    );
  }

  // TASK 2: Approve
  void approveByPrincipal() {
    if (_status != LeaveRequestStatus.pendingPrincipalReview) {
      throw StateError('Only pending requests can be approved.');
    }
    _status = LeaveRequestStatus.approved;
  }

  // TASK 3: Reject
  void rejectByPrincipal() {
    if (_status != LeaveRequestStatus.pendingPrincipalReview) {
      throw StateError('Only pending requests can be rejected.');
    }
    _status = LeaveRequestStatus.rejected;
  }
} 