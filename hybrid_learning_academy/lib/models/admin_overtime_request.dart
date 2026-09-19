class OvertimeRequest {
  String staff;
  String date;
  String reason;
  String hour;
  String status;
  OvertimeRequest({required this.staff, required this.date, required this.reason, required this.hour, this.status = 'pending'});
}