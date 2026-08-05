import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ClockInOutScreen extends StatefulWidget {
  const ClockInOutScreen({super.key});

  @override
  State<ClockInOutScreen> createState() => _ClockInOutScreenState();
}

class _ClockInOutScreenState extends State<ClockInOutScreen> {
  DateTime _currentTime = DateTime.now();
  Timer? _timer;
  String staffName = 'Staff Name';

  static const String baseUrl = 'http://192.168.0.213:5115';

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
    loadStaffName();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> loadStaffName() async {
    const storage = FlutterSecureStorage();
    String? name = await storage.read(key: "staffName");
    if (name != null) {
      setState(() {
        staffName = name;
      });
    }
  }

  Future<int?> getLoggedInStaffId() async {
    const storage = FlutterSecureStorage();
    String? staffIdString = await storage.read(key: "staffId");
    if (staffIdString == null) {
      return null;
    }
    return int.tryParse(staffIdString);
  }

  Future<XFile?> takePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    return photo;
  }

  Future<String?> photoToBase64(XFile photo) async {
    final bytes = await photo.readAsBytes();
    return base64Encode(bytes);
  }

  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<bool> isWithinSchoolArea(Position position) async {
    const double schoolLatitude = -29.8525;
    const double schoolLongitude = 31.0036;
    const double allowedRadiusMeters = 2000000; // TEMP: wide for testing

    double distance = Geolocator.distanceBetween(
      schoolLatitude,
      schoolLongitude,
      position.latitude,
      position.longitude,
    );

    return distance <= allowedRadiusMeters;
  }

  String attendanceStatus = 'Not clocked in';

  Future<bool> confirmClockOut() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clock Out'),
        content: const Text('Are you sure you want to clock out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clock Out'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> sendClockIn(Position position, XFile photo) async {
    int? staffId = await getLoggedInStaffId();

    if (staffId == null) {
      debugPrint('Not logged in — cannot clock in');
      return;
    }

    String? photoBase64 = await photoToBase64(photo);

    final response = await http.post(
      Uri.parse('$baseUrl/api/staffattendance/ClockIn'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'staffId': staffId,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'photoBase64': photoBase64,
      }),
    );
      
    if (response.statusCode == 200) 
    {
      debugPrint('Clock-in successful: ${response.body}');
      setState(() 
      {
        attendanceStatus = 'Clocked In';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Clocked in successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } 
    else {
      debugPrint('Clock-in failed: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> sendClockOut(Position position, XFile photo) async {
    int? staffId = await getLoggedInStaffId();

    if (staffId == null) {
      debugPrint('Not logged in — cannot clock out');
      return;
    }

    String? photoBase64 = await photoToBase64(photo);

    final response = await http.post(
      Uri.parse('$baseUrl/api/staffattendance/ClockOut'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'staffId': staffId,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'photoBase64': photoBase64,
      }),
    );

    if (response.statusCode == 200)
    {
      debugPrint('Clock-out successful: ${response.body}');
       setState(() {
    attendanceStatus = 'Clocked Out';
  });
    } 
    else
     {
      debugPrint('Clock-out failed: ${response.statusCode} - ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clock In / Out'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                const CircleAvatar(radius: 30, child: Icon(Icons.person, size: 30)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      staffName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  '${_currentTime.hour.toString().padLeft(2, '0')}:${_currentTime.minute.toString().padLeft(2, '0')}:${_currentTime.second.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
                Text(DateFormat('EEEE, d MMMM yyyy').format(_currentTime)),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  Position? position = await getCurrentLocation();
                  if (position == null) {
                    debugPrint('Could not get location');
                    return;
                  }

                  bool withinSchool = await isWithinSchoolArea(position);
                  if (!withinSchool) {
                    debugPrint('Outside school area — blocked');
                    return;
                  }

                  debugPrint('Within school area — opening camera');
                  XFile? photo = await takePhoto();
                  if (photo == null) {
                    debugPrint('No photo taken — cancelling clock in');
                    return;
                  }

                  debugPrint('Photo taken: ${photo.path}');
                  await sendClockIn(position, photo);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/icons/clock_in.png', width: 60, height: 60),
                    const SizedBox(height: 8),
                    const Text('CLOCK IN'),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () async {
                  bool confirmed = await confirmClockOut();
                  if (!confirmed) {
                    debugPrint('Clock out cancelled by user');
                    return;
                  }

                  Position? position = await getCurrentLocation();
                  if (position == null) {
                    debugPrint('Could not get location');
                    return;
                  }

                  bool withinSchool = await isWithinSchoolArea(position);
                  if (!withinSchool) {
                    debugPrint('Outside school area — blocked');
                    return;
                  }

                  debugPrint('Within school area — opening camera');
                  XFile? photo = await takePhoto();
                  if (photo == null) {
                    debugPrint('No photo taken — cancelling clock out');
                    return;
                  }

                  debugPrint('Photo taken: ${photo.path}');
                  await sendClockOut(position, photo);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/icons/clock_out.png', width: 60, height: 60),
                    const SizedBox(height: 8),
                    const Text('CLOCK OUT'),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
           child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(attendanceStatus),
                const SizedBox(width: 8),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: attendanceStatus == 'Clocked In' ? Colors.green : const Color.fromARGB(255, 179, 8, 8),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}