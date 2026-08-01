import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

class ClockInOutScreen extends StatefulWidget {
  const ClockInOutScreen({super.key});

  @override
  State<ClockInOutScreen> createState() => _ClockInOutScreenState();
}

class _ClockInOutScreenState extends State<ClockInOutScreen> {
  DateTime _currentTime = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<XFile?> takePhoto() async 
  {
  final ImagePicker picker = ImagePicker();
  final XFile? photo = await picker.pickImage(source: ImageSource.camera);
  return photo;
  }

  //  current GPS position
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

  // within range of the school
  Future<bool> isWithinSchoolArea(Position position) async {
    const double schoolLatitude = -29.8525;  // dut is being used now for testing purposes
    const double schoolLongitude = 31.0036;
    const double allowedRadiusMeters = 2000000;  // This was changed from 200 => 2000000 for testing as well

    double distance = Geolocator.distanceBetween(
      schoolLatitude,
      schoolLongitude,
      position.latitude,
      position.longitude,
    );

    return distance <= allowedRadiusMeters;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clock In / Out'),
      ),
      body: Column(
        children: [
          Container( // profile card
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                const CircleAvatar(radius: 30, child: Icon(Icons.person, size: 30)),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Staff Name',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Container( // clock card
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

          Row( // buttons
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async 
                {
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

                  if (photo != null) {
                    debugPrint('Photo taken: ${photo.path}');
                  } else {
                    debugPrint('No photo taken');
                  }
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
                onPressed: () async 
                {
                  Position? position = await getCurrentLocation();

                  if (position == null) {
                    debugPrint('Could not get location');
                    return;
                  }

                  bool withinSchool = await isWithinSchoolArea(position);

                  if (!withinSchool) {
                    debugPrint(' Outside school area — blocked');
                    return;
                  }

                  debugPrint('Within school area — opening camera');
                  XFile? photo = await takePhoto();

                  if (photo != null) {
                    debugPrint('Photo taken: ${photo.path}');
                  } else {
                    debugPrint('No photo taken');
                  }
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

          Container( // status card
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Last Clocked In: 7:54 AM'),
                const SizedBox(width: 8),
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.green,
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