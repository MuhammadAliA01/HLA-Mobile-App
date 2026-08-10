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

  DateTime? _clockInTime; // when they clocked in today
  Duration _workedDuration = Duration.zero;

  String? _lastClockInDate; // yyyy-MM-dd of the last successful clock-in, so we know if today is already used

  static const String baseUrl = 'http://192.168.0.159:7205';

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
        if (_clockInTime != null) {
          _workedDuration = _currentTime.difference(_clockInTime!);
        }
      });
    });
    loadStaffName();
    loadClockInTime();
    loadLastClockInDate();
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

  Future<void> loadClockInTime() async {
    const storage = FlutterSecureStorage();
    final staffId = await getLoggedInStaffId();
    if (staffId == null) return;
    String? saved = await storage.read(key: "clockInTime_$staffId");
    if (saved != null) {
      setState(() {
        _clockInTime = DateTime.parse(saved);
        attendanceStatus = 'Clocked In';
      });
    }
  }

  Future<void> loadLastClockInDate() async {
    const storage = FlutterSecureStorage();
    final staffId = await getLoggedInStaffId();
    if (staffId == null) return;
    String? saved = await storage.read(key: "lastClockInDate_$staffId");
    if (saved != null) {
      setState(() {
        _lastClockInDate = saved;
      });
    }
  }

  String _todayDateString() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
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
    const double allowedRadiusMeters = 20000000; //  wide for testing

    double distance = Geolocator.distanceBetween(
      schoolLatitude,
      schoolLongitude,
      position.latitude,
      position.longitude,
    );

    return distance <= allowedRadiusMeters;
  }

  String attendanceStatus = 'Not clocked in';
  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showAlertDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clock In'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

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

    var uri = Uri.parse('$baseUrl/api/staffattendance/ClockIn');
    var request = http.MultipartRequest('POST', uri);

    
    request.fields['staffId'] = staffId.toString();
    request.fields['latitude'] = position.latitude.toString();
    request.fields['longitude'] = position.longitude.toString();

    
    request.files.add(await http.MultipartFile.fromPath(
      'Photo', // Must match the property name in your C# ClockInRequest
      photo.path,
    ));

    try {
      var streamedResponse = await request.send();
      var responseBody = await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode == 200) {
        debugPrint('Clock-in successful: $responseBody');
        final now = DateTime.now();
        final todayString = _todayDateString();
        setState(() {
          attendanceStatus = 'Clocked In';
          _clockInTime = now;
          _lastClockInDate = todayString;
        });
        const storage = FlutterSecureStorage();
        await storage.write(key: "clockInTime_$staffId", value: now.toIso8601String());
        await storage.write(key: "lastClockInDate_$staffId", value: todayString);
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
      } else {
        debugPrint('Clock-in failed: ${streamedResponse.statusCode} - $responseBody');
        String message = 'Clock-in failed. Server returned: ${streamedResponse.statusCode}';
        try {
          final decoded = jsonDecode(responseBody);
          if (decoded is Map && decoded['message'] != null) {
            message = decoded['message'];
          }
        } catch (_) {
          // couldn't parse JSON, fall back to the generic message above
        }
        // If the server says they already clocked in today, remember that locally too,
        // so we don't open the camera again next time without asking.
        if (message.toLowerCase().contains('already clocked in')) {
          const storage = FlutterSecureStorage();
          final todayString = _todayDateString();
          await storage.write(key: "lastClockInDate_$staffId", value: todayString);
          setState(() {
            _lastClockInDate = todayString;
          });
        }
        _showAlertDialog(message);
      }
    } catch (e) {
      _showError('Network error during Clock In.');
    }
  }

  Future<void> sendClockOut(Position position, XFile photo) async {
    int? staffId = await getLoggedInStaffId();

    if (staffId == null) {
      debugPrint('Not logged in — cannot clock out');
      return;
    }

    var uri = Uri.parse('$baseUrl/api/staffattendance/ClockOut');
    var request = http.MultipartRequest('POST', uri);

    
    request.fields['staffId'] = staffId.toString();
    request.fields['latitude'] = position.latitude.toString();
    request.fields['longitude'] = position.longitude.toString();

    
    request.files.add(await http.MultipartFile.fromPath(
      'Photo',
      photo.path,
    ));

    try {
      var streamedResponse = await request.send();
      var responseBody = await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode == 200) {
        setState(() {
          attendanceStatus = 'Clocked Out';
          _clockInTime = null;
          _workedDuration = Duration.zero;
        });
        const storage = FlutterSecureStorage();
        await storage.delete(key: "clockInTime_$staffId");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Clocked out successfully!'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        _showError('Clock-out failed. Server returned: ${streamedResponse.statusCode}');
      }
    } catch (e) {
      _showError('Network error during Clock Out.');
    }
  }

  String formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(d.inHours);
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {

      double screenWidth = MediaQuery.sizeOf(context).width;
    return Scaffold(
      backgroundColor: Colors.white,
      
      body: Column(
        children: [
         Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
  ),
  child: Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      const CircleAvatar(
        radius: 30,
        child: Icon(Icons.person, size: 30),
      ),

      const SizedBox(height: 10),

      Text(
        staffName,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
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
                  style: const TextStyle(fontSize: 70, ),
                ),
                Text(DateFormat('EEEE, d MMMM yyyy').format(_currentTime)),
              ],
            ),
          ),

          const SizedBox(height: 16),

          if (attendanceStatus == 'Clocked In')
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text('Worked today', style: TextStyle(color: Colors.grey)),
                  Text(
                    formatDuration(_workedDuration),
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

          Column(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 300,
                height: 50,
                  child: 
                  ElevatedButton(
                
                // REQUIREMENT B: Disable button if already clocked in
                onPressed: attendanceStatus == 'Clocked In' 
                    ? null 
                    : () async {
                  // If they already clocked in today (even after clocking back out),
                  // stop them here — don't open the camera for nothing.
                  if (_lastClockInDate == _todayDateString()) {
                    _showAlertDialog('You have already clocked in today. Only one clock-in per day is allowed.');
                    return;
                  }

                  Position? position = await getCurrentLocation();
                  if (position == null) {
                    _showError('Could not get GPS location. Please enable location services.');
                    return;
                  }

                  bool withinSchool = await isWithinSchoolArea(position);
                  if (!withinSchool) {
                    // REQUIREMENT A: Show error if outside school
                    _showError('Action Blocked: You must be inside the school premises to clock in.');
                    return;
                  }

                  XFile? photo = await takePhoto();
                  if (photo == null) {
                    return; // User cancelled photo, do nothing
                  }

                  await sendClockIn(position, photo);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  disabledBackgroundColor: Colors.grey.shade400, // Greys out when disabled
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    const Text('CLOCK IN', style: TextStyle(color: Colors.white),),
                  ],
                ),
              ),
              ),
              
              const SizedBox(width: 20),

              SizedBox(
                width: 300,
                height: 50,
                  child: 
                  ElevatedButton(
                //  Disabled clock out if they aren't clocked in
                onPressed: attendanceStatus != 'Clocked In'
                    ? null
                    : () async {
                  bool confirmed = await confirmClockOut();
                  if (!confirmed) {
                    return;
                  }

                  Position? position = await getCurrentLocation();
                  if (position == null) {
                    _showError('Could not get GPS location. Please enable location services.');
                    return;
                  }

                  bool withinSchool = await isWithinSchoolArea(position);
                  if (!withinSchool) {
                    // REQUIREMENT A: Show error if outside school
                    _showError('Action Blocked: You must be inside the school premises to clock out.');
                    return;
                  }

                  XFile? photo = await takePhoto();
                  if (photo == null) {
                    return; // User cancelled photo, do nothing
                  }

                  await sendClockOut(position, photo);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  disabledBackgroundColor: Colors.grey.shade400, // Greys out when disabled
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    const Text('CLOCK OUT'),
                  ],
                ),
              ),
              )

              
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
                Text(attendanceStatus, style: TextStyle(fontSize: 18),),
                const SizedBox(width: 8),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: attendanceStatus == 'Clocked In' ? Colors.green : Colors.deepOrange,
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