import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class StaffSchedulePage extends StatefulWidget {
  const StaffSchedulePage({super.key});

  @override
  State<StaffSchedulePage> createState() => _StaffSchedulePageState();
}

class _StaffSchedulePageState extends State<StaffSchedulePage> {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  List<dynamic> schedules = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadSchedule();
  }

  Future<void> loadSchedule() async {
    try {
      final staffId = await storage.read(key: "staffId");

      if (staffId == null) {
        setState(() {
          isLoading = false;
          errorMessage = "Staff ID not found. Please log in again.";
        });
        return;
      }

      final response = await http.get(
        Uri.parse(
          "http://localhost:7205/api/MobileStaffSchedule/staff/$staffId",
        ),
        headers: {
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          schedules = data;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage =
              "Failed to load schedule. Status: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Error loading schedule: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Schedule"),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            errorMessage!,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (schedules.isEmpty) {
      return const Center(
        child: Text(
          "You have no classes assigned.",
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadSchedule,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: schedules.length,
        itemBuilder: (context, index) {
          final schedule = schedules[index];

          return _buildScheduleCard(schedule);
        },
      ),
    );
  }

  Widget _buildScheduleCard(dynamic schedule) {
    final date = DateTime.parse(
      schedule["scheduleDate"].toString(),
    );

    final formattedDate =
        "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.school,
              size: 40,
            ),

            const SizedBox(height: 12),

            Text(
              schedule["className"] ?? 
                  "Class ${schedule["classId"]}",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                const Icon(Icons.calendar_today, size: 18),
                const SizedBox(width: 8),
                Text(formattedDate),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.access_time, size: 18),
                const SizedBox(width: 8),
                Text(
                  schedule["shiftType"] ?? "Unknown shift",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}