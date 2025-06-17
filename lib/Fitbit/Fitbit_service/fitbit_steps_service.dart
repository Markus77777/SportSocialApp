import 'dart:convert';
import 'package:http/http.dart' as http;
import 'fitbit_auth_service.dart';

class FitbitStepsService {
final FitbitAuthService auth = FitbitAuthService(); 


  
  Future<int?> fetchTodaySteps() async {
    await auth.refreshAccessTokenIfNeeded();
    if (auth.accessToken == null) return null;

    final date = _formatDate(DateTime.now());

    final url = Uri.parse('https://api.fitbit.com/1/user/-/activities/date/$date.json');

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer ${auth.accessToken}',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['summary']?['steps'] ?? 0;
    }

    return null;
  }

  /// 取得以週日為起點的一週步數資料（傳入任何日期都會自動對齊該週的週日）
  Future<Map<String, dynamic>?> fetchWeeklySteps(DateTime referenceDate) async {
    await auth.refreshAccessTokenIfNeeded();
    if (auth.accessToken == null) return null;

    final sunday = referenceDate.subtract(Duration(days: referenceDate.weekday % 7));
    final sundayStr = _formatDate(sunday);
    final saturday = sunday.add(const Duration(days: 6));
    final saturdayStr = _formatDate(saturday);

    final url = Uri.parse(
        'https://api.fitbit.com/1/user/-/activities/steps/date/$sundayStr/$saturdayStr.json');

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer ${auth.accessToken}',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final stepsList = (data['activities-steps'] as List<dynamic>)
          .map((e) => {
                'date': e['dateTime'],
                'value': int.tryParse(e['value']) ?? 0,
              })
          .toList();

      return {
        'type': 'weekly',
        'startDate': sundayStr,
        'endDate': saturdayStr,
        'data': stepsList,
      };
    }

    return null;
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
