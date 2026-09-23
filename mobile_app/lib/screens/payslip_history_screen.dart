import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:intl/intl.dart';

import '../models/payslip_history_item.dart';

const String baseUrl = 'http://10.36.179.40:7205';

class PayslipHistoryScreen extends StatefulWidget {
  final int staffId; // Pass the active user's staff ID

  const PayslipHistoryScreen({super.key, required this.staffId});

  @override
  State<PayslipHistoryScreen> createState() => _PayslipHistoryScreenState();
}

class _PayslipHistoryScreenState extends State<PayslipHistoryScreen> {
  late Future<List<PayslipHistoryItem>> _historyFuture;
  final Set<int> _downloadingIds = {};

  @override
  void initState() {
    super.initState();
    _historyFuture = _fetchHistory();
  }

  Future<List<PayslipHistoryItem>> _fetchHistory() async {
    final uri = Uri.parse('$baseUrl/api/mobile/payslip-history')
        .replace(queryParameters: {'staffId': widget.staffId.toString()});

    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data =
          response.body.isEmpty ? [] : jsonDecode(response.body) as List<dynamic>;
      return data
          .map((item) => PayslipHistoryItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load payslips (${response.statusCode}): ${response.body}');
    }
  }

  Future<void> _downloadPayslip(PayslipHistoryItem item) async {
    setState(() => _downloadingIds.add(item.payslipId));

    try {
      final uri = Uri.parse('$baseUrl/api/mobile/payslip-history/${item.payslipId}/download')
          .replace(queryParameters: {'staffId': widget.staffId.toString()});

      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception('Download failed (${response.statusCode}).');
      }

      final Uint8List bytes = response.bodyBytes;
      final dir = await getTemporaryDirectory();
      final fileName =
          'Payslip_${DateFormat('yyyyMM').format(item.payPeriodStart)}.pdf';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes);

      await OpenFilex.open(file.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not download payslip: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _downloadingIds.remove(item.payslipId));
      }
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _historyFuture = _fetchHistory();
    });
    await _historyFuture;
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Generated':
        return Colors.green;
      case 'Failed':
        return Colors.red;
      case 'PendingConfirmation':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Payslip History')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<PayslipHistoryItem>>(
          future: _historyFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return ListView(
                children: [
                  const SizedBox(height: 80),
                  Icon(Icons.error_outline, size: 48, color: Colors.grey[500]),
                  const SizedBox(height: 12),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        '${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              );
            }

            final items = snapshot.data ?? [];
            if (items.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 80),
                  Center(child: Text('No payslips found yet.')),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isDownloading = _downloadingIds.contains(item.payslipId);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(
                      '${dateFormat.format(item.payPeriodStart)} - '
                      '${dateFormat.format(item.payPeriodEnd)}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _statusColor(item.status).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                item.status,
                                style: TextStyle(
                                  color: _statusColor(item.status),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (item.status == 'Failed' &&
                            item.failureReason != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            item.failureReason!,
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                    trailing: item.isDownloadable
                        ? (isDownloading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : IconButton(
                                icon: const Icon(Icons.download),
                                onPressed: () => _downloadPayslip(item),
                              ))
                        : null,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}