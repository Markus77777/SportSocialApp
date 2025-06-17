import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'fitbit_auth_service.dart';

class FitbitBreathingService {
 final FitbitAuthService auth = FitbitAuthService(); 

  Future<double?> fetchBreathingRate() async {
    await auth.refreshAccessTokenIfNeeded();
    if (auth.accessToken == null) return null;

    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final url = Uri.parse('https://api.fitbit.com/1/user/-/br/date/$date.json');

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer ${auth.accessToken}',
    });

    if (response.statusCode == 200) {
      final list = jsonDecode(response.body)['br'] as List?;
      if (list != null && list.isNotEmpty) {
        return (list.first['value']?['breathingRate'])?.toDouble();
      }
    }

    return null;
  }

  Future<Map<String, dynamic>?> fetchWeeklyBreathingRate(DateTime referenceDate) async {
    await auth.refreshAccessTokenIfNeeded();
    if (auth.accessToken == null) return null;

    final sunday = referenceDate.subtract(Duration(days: referenceDate.weekday % 7));
    final formatter = DateFormat('yyyy-MM-dd');
    final startStr = formatter.format(sunday);
    final endStr = formatter.format(sunday.add(const Duration(days: 6)));

    final url = Uri.parse('https://api.fitbit.com/1/user/-/br/date/$startStr/$endStr.json');

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer ${auth.accessToken}',
    });

    print('[BreathingRate] API 回應狀態碼: ${response.statusCode}');
    print('[BreathingRate] API 回應內容: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final brList = data['br'] as List? ?? [];

      final weeklyData = brList
          .where((e) => e['value']?['breathingRate'] != null)
          .map((e) => {
                'date': e['dateTime'],
                'value': (e['value']['breathingRate'] as num).toDouble(),
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
