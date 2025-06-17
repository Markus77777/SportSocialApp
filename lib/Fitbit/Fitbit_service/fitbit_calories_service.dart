import 'dart:convert';
import 'package:http/http.dart' as http;
import 'fitbit_auth_service.dart';

class FitbitCaloriesService {
   final FitbitAuthService auth = FitbitAuthService(); 

  /// 查詢今天的總熱量消耗
  Future<int?> fetchCaloriesOut() async {
    await auth.refreshAccessTokenIfNeeded();
    if (auth.accessToken == null) return null;

    final date = _formatDate(DateTime.now());
    final url = Uri.parse('https://api.fitbit.com/1/user/-/activities/date/$date.json');

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer ${auth.accessToken}',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['summary']?['caloriesOut'] ?? 0;
    }

    return null;
  }

  /// 查詢整週的每日熱量消耗
  Future<Map<String, dynamic>?> fetchWeeklyCalories(DateTime referenceDate) async {
    await auth.refreshAccessTokenIfNeeded();
    if (auth.accessToken == null) return null;

    // 將任意日期對齊到當週的週日
    final sunday = referenceDate.subtract(Duration(days: referenceDate.weekday % 7));
    final saturday = sunday.add(const Duration(days: 6));
    final startStr = _formatDate(sunday);
    final endStr = _formatDate(saturday);

    final url = Uri.parse(
      'https://api.fitbit.com/1/user/-/activities/calories/date/$startStr/$endStr.json',
    );

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer ${auth.accessToken}',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final rawList = data['activities-calories'] as List<dynamic>?;

      if (rawList == null || rawList.isEmpty) return null;

      final cleanedList = rawList.map((e) {
        return {
          'date': e['dateTime'],
          'value': int.tryParse(e['value']) ?? 0,
        };
      }).toList();

      return {
        'type': 'weekly',
        'startDate': startStr,
        'endDate': endStr,
        'data': cleanedList,
      };
    }

    return null;
  }

  /// 格式化日期為 yyyy-MM-dd
  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
