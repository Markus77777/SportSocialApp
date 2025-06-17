import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'fitbit_auth_service.dart';

class FitbitSpO2Service {
final FitbitAuthService auth = FitbitAuthService(); 


  Future<double?> fetchTodaySpO2() async {
    await auth.refreshAccessTokenIfNeeded();
    if (auth.accessToken == null) return null;

    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final url = Uri.parse('https://api.fitbit.com/1/user/-/spo2/date/$date.json');

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer ${auth.accessToken}',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['value']?['avg'])?.toDouble();
    }

    return null;
  }

Future<Map<String, dynamic>?> fetchWeeklySpO2(DateTime referenceDate) async {
  await auth.refreshAccessTokenIfNeeded();
  if (auth.accessToken == null) return null;

  final sunday = referenceDate.subtract(Duration(days: referenceDate.weekday % 7));
  final formatter = DateFormat('yyyy-MM-dd');
  final startStr = formatter.format(sunday);
  final endStr = formatter.format(sunday.add(const Duration(days: 6)));

  final url = Uri.parse(
    'https://api.fitbit.com/1/user/-/spo2/date/$startStr/$endStr.json',
  );

  final response = await http.get(url, headers: {
    'Authorization': 'Bearer ${auth.accessToken}',
  });

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);

    final weeklyData = data
        .where((e) => e['value']?['avg'] != null)
        .map((e) => {
              'date': e['dateTime'],
              'value': (e['value']['avg'] as num).toDouble(),
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
