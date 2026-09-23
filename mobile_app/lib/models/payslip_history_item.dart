class PayslipHistoryItem {
  final int payslipId;
  final DateTime payPeriodStart;
  final DateTime payPeriodEnd;
  final String status;
  final String? failureReason;
  final int currentVersion;
  final DateTime generatedAt;

  PayslipHistoryItem({
    required this.payslipId,
    required this.payPeriodStart,
    required this.payPeriodEnd,
    required this.status,
    this.failureReason,
    required this.currentVersion,
    required this.generatedAt,
  });

  bool get isDownloadable => status == 'Generated';

  factory PayslipHistoryItem.fromJson(Map<String, dynamic> json) {
    return PayslipHistoryItem(
      payslipId: json['payslipId'] as int,
      payPeriodStart: DateTime.parse(json['payPeriodStart'] as String),
      payPeriodEnd: DateTime.parse(json['payPeriodEnd'] as String),
      status: json['status'] as String,
      failureReason: json['failureReason'] as String?,
      currentVersion: json['currentVersion'] as int,
      generatedAt: DateTime.parse(json['generatedAt'] as String),
    );
  }
}