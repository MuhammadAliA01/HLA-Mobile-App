import 'package:flutter/material.dart';
import '../models/admin_overtime_request.dart';

class AdminOvertimePage extends StatefulWidget {
  @override
  _AdminOvertimePageState createState() => _AdminOvertimePageState();
}

class _AdminOvertimePageState extends State<AdminOvertimePage> {
  // YOUR VARIABLES - these control the 3 tabs
  List<OvertimeRequest> pending = [
    OvertimeRequest(staff: "Tashana N.", date: "6 Sep 2026, 2h extra", reason: "Exam marking", hour: "2"),
  ];
  List<OvertimeRequest> approved = [];
  List<OvertimeRequest> rejected = [];
  String tempRejectReason = "";

  Widget buildCard(OvertimeRequest req, {bool showActions = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: Color(0xFFFFF3D6), borderRadius: BorderRadius.circular(16)),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(req.staff, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(req.date),
          Text(req.reason),
          if (showActions)
            Row(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () {
                    setState(() {
                      req.status = 'approved';
                      approved.add(req);
                      pending.remove(req);
                    });
                  },
                  child: Text("Approve"),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFB71C1C)),
                  onPressed: () {
                    setState(() {
                      req.status = 'rejected';
                      rejected.add(req);
                      pending.remove(req);
                    });
                  },
                  child: Text("Reject"),
                ),
              ],
            )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFFB71C1C),
          title: Text("Overtime Requests"),
          bottom: TabBar(tabs: [
            Tab(text: "Pending (${pending.length})"),
            Tab(text: "Approved (${approved.length})"),
            Tab(text: "Rejected (${rejected.length})"),
          ]),
        ),
        body: TabBarView(
          children: [
            ListView(children: pending.map((r) => buildCard(r, showActions: true)).toList()),
            ListView(children: approved.map((r) => buildCard(r)).toList()),
            ListView(children: rejected.map((r) => buildCard(r)).toList()),
          ],
        ),
      ),
    );
  }
}