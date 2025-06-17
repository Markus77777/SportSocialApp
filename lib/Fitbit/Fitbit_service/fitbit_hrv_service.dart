import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'fitbit_auth_service.dart';

class FitbitHRVService {
final FitbitAuthService auth = FitbitAuthService(); 


  Future<double?> fetchHRV() async {
    await auth.refreshAccessTokenIfNeeded();
    if (auth.accessToken == null) return null;

    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final url = Uri.parse('https://api.fitbit.com/1/user/-/hrv/date/$date.json');

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer ${auth.accessToken}',
    });

    if (response.statusCode == 200) {
      final list = jsonDecode(response.body)['hrv'] as List?;
      if (list != null && list.isNotEmpty) {
        return (list.first['value']?['dailyRmssd'])?.toDouble();
      }
    }

    return null;
  }

  Future<Map<String, dynamic>?> fetchWeeklyHRV(DateTime referenceDate) async {
    await auth.refreshAccessTokenIfNeeded();
    if (auth.accessToken == null) return null;

    final sunday = referenceDate.subtract(Duration(days: referenceDate.weekday % 7));
    final formatter = DateFormat('yyyy-MM-dd');
    final startStr = formatter.format(sunday);
    final endStr = formatter.format(sunday.add(const Duration(days: 6)));

    final url = Uri.parse('https://api.fitbit.com/1/user/-/hrv/date/$startStr/$endStr.json');

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer ${auth.accessToken}',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final hrvList = data['hrv'] as List? ?? [];

      final weeklyData = hrvList
          .where((e) => e['value']?['dailyRmssd'] != null)
          .map((e) => {
                'date': e['dateTime'],
                'value': (e['value']['dailyRmssd'] as num).toDouble(),
              })
          .toList();

      return {
        'type': 'weekly',
        'startDate': startStr,
        'endDate': endStr,
        'data': weeklyData,
      };
    }

    return null;
  }
}
