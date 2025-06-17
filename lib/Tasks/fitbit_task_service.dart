import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_app1/Fitbit/Fitbit_service/fitbit_auth_service.dart';

class FitbitTaskService {
 final FitbitAuthService auth = FitbitAuthService();

Future<int?> fetchTotalSteps(DateTime start, DateTime end) async {
  await auth.refreshAccessTokenIfNeeded();
  if (auth.accessToken == null) return null;

  final dateStr = DateFormat('yyyy-MM-dd').format(start);
  final startTimeStr = DateFormat('HH:mm').format(start);
  final endTimeStr = DateFormat('HH:mm').format(end);

  final url = Uri.parse(
    'https://api.fitbit.com/1/user/-/activities/steps/date/$dateStr/$dateStr/1min/time/$startTimeStr/$endTimeStr.json',
  );

  final response = await http.get(url, headers: {
    'Authorization': 'Bearer ${auth.accessToken}',
  });

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final dataset = data['activities-steps-intraday']?['dataset'] as List?;
    if (dataset == null) return 0;

    final total = dataset.fold<double>(0, (sum, e) => sum + (e['value'] as num).toDouble());
    return total.round(); 
  }

  return null;
}

Future<int?> fetchTotalCalories(DateTime start, DateTime end) async {
  await auth.refreshAccessTokenIfNeeded();
  if (auth.accessToken == null) return null;

  final dateStr = DateFormat('yyyy-MM-dd').format(start);
  final startTimeStr = DateFormat('HH:mm').format(start);
  final endTimeStr = DateFormat('HH:mm').format(end);

  final url = Uri.parse(
    'https://api.fitbit.com/1/user/-/activities/calories/date/$dateStr/$dateStr/1min/time/$startTimeStr/$endTimeStr.json',
  );

  final response = await http.get(url, headers: {
    'Authorization': 'Bearer ${auth.accessToken}',
  });

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final dataset = data['activities-calories-intraday']?['dataset'] as List?;
    if (dataset == null) return 0;

    final total = dataset.fold<double>(0, (sum, e) => sum + (e['value'] as num).toDouble());
    return total.round();  
  }

  return null;
}


Future<List<Map<String, dynamic>>> fetchHeartRateData(DateTime start, DateTime end) async {
  await auth.refreshAccessTokenIfNeeded();
  if (auth.accessToken == null) return [];

  final dateStr = DateFormat('yyyy-MM-dd').format(start);
  final startTimeStr = DateFormat('HH:mm').format(start);
  final endTimeStr = DateFormat('HH:mm').format(end);

  final url = Uri.parse(
    'https://api.fitbit.com/1/user/-/activities/heart/date/$dateStr/$dateStr/5min/time/$startTimeStr/$endTimeStr.json',
  );

  final response = await http.get(url, headers: {
    'Authorization': 'Bearer ${auth.accessToken}',
  });

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final dataset = data['activities-heart-intraday']?['dataset'] as List?;
    if (dataset == null || dataset.isEmpty) return [];

    // 安全轉換並過濾時間區間內的資料
    return dataset.whereType<Map>().where((e) {
      try {
        final time = DateFormat('HH:mm:ss').parse(e['time']);
        final timestamp = DateTime(start.year, start.month, start.day, time.hour, time.minute);
        return timestamp.isAfter(start) && timestamp.isBefore(end);
      } catch (_) {
        return false;
      }
    }).cast<Map<String, dynamic>>().toList();
  }

  return [];
}

}
