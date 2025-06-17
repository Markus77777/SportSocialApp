import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';

class RunPage extends StatefulWidget {
  const RunPage({super.key});

  @override
  State<RunPage> createState() => _RunPageState();
}

class _RunPageState extends State<RunPage> {
  Position? _currentPosition;
  double _totalDistance = 0.0;
  Position? _lastPosition;
  bool _isTracking = false;
  final List<LatLng> _routePoints = [];
  DateTime? _startTime;
  DateTime? _endTime;
  bool _isAutoMove = true;

  final LatLng _defaultLocation = const LatLng(25.0330, 121.5654);
  final MapController _mapController = MapController();

  Timer? _timer;
  int _elapsedSeconds = 0;
  StreamSubscription<Position>? _positionSubscription;
  DateTime? _lastUpdateTime;

  @override
  void initState() {
    super.initState();
    _checkPermission().then((_) => _getCurrentLocation());
  }

  Future<void> _checkPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      debugPrint('未授權定位權限');
      return;
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (!mounted) return;
      setState(() {
        _currentPosition = position;
      });
      _moveCamera(position);
    } catch (e) {
      debugPrint('取得定位失敗: $e');
    }
  }

  void _startTracking() {
    setState(() {
      _isTracking = true;
      _startTime = DateTime.now();
    });

    _elapsedSeconds = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isTracking) {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5,
      ),
    ).listen((Position position) {
      if (!mounted || !_isTracking) return;

      final now = DateTime.now();
      if (_lastUpdateTime != null && now.difference(_lastUpdateTime!) < const Duration(seconds: 1)) {
        return; // 避免太頻繁更新
      }
      _lastUpdateTime = now;

      if (_lastPosition != null) {
        _totalDistance += Geolocator.distanceBetween(
          _lastPosition!.latitude,
          _lastPosition!.longitude,
          position.latitude,
          position.longitude,
        );
      }

      _lastPosition = position;
      _routePoints.add(LatLng(position.latitude, position.longitude));
      _moveCamera(position);

      setState(() {
        _currentPosition = position;
      });
    });
  }

  void _moveCamera(Position position) {
    if (!_isAutoMove) return;

    final currentCenter = _mapController.center;
    final newCenter = LatLng(position.latitude, position.longitude);
    final distance = const Distance().as(LengthUnit.Meter, currentCenter, newCenter);

    if (distance > 10) {
      _mapController.move(newCenter, 17.0);
    }
  }

  void _stopTracking() {
    setState(() {
      _isTracking = false;
      _endTime = DateTime.now();
      _lastPosition = null;
    });

    _timer?.cancel();
    _positionSubscription?.cancel();

    if (_startTime != null && _endTime != null) {
      final duration = _endTime!.difference(_startTime!);
      Navigator.pop(context, {
        'distance': _totalDistance,
        'duration': duration,
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    if (_timer?.isActive ?? false) _timer?.cancel();
    _positionSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final center = _currentPosition != null
        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
        : _defaultLocation;

    String formatTime(int seconds) {
      final duration = Duration(seconds: seconds);
      final minutes = duration.inMinutes.toString().padLeft(2, '0');
      final secs = (duration.inSeconds % 60).toString().padLeft(2, '0');
      return '$minutes:$secs';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('跑步中')),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(center: center, zoom: 17),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      strokeWidth: 5.0,
                      color: Colors.blue,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    if (_currentPosition != null)
                      Marker(
                        width: 40,
                        height: 40,
                        point: center,
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '距離：${(_totalDistance / 1000).toStringAsFixed(2)} 公里',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '時間：${formatTime(_elapsedSeconds)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _isTracking
                      ? ElevatedButton(
                          onPressed: _stopTracking,
                          child: const Text('停止跑步'),
                        )
                      : ElevatedButton(
                          onPressed: _startTracking,
                          child: const Text('開始跑步'),
                        ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _getCurrentLocation,
                    child: const Text('更新當前位置'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
