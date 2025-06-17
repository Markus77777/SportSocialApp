import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'fitbit_auth_service.dart';

class FitbitTemperatureService {
final FitbitAuthService auth = FitbitAuthService(); 


  Future<double?> fetchTodaySkinTemperature() async {
    await auth.refreshAccessTokenIfNeeded();
    if (auth.accessToken == null) return null;

    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final url = Uri.parse('https://api.fitbit.com/1/user/-/temp/skin/date/$date.json');

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer ${auth.accessToken}',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final tempList = data['tempSkin'] as List?;
      if (tempList != null && tempList.isNotEmpty) {
        final variation = tempList[0]['value']?['nightlyRelative'];
        if (variation is num) return variation.toDouble();
      }
    }

    return null;
  }

  Future<Map<String, dynamic>?> fetchWeeklySkinTemperature(DateTime referenceDate) async {
    await auth.refreshAccessTokenIfNeeded();
    if (auth.accessToken == null) return null;

    final sunday = referenceDate.subtract(Duration(days: referenceDate.weekday % 7));
    final formatter = DateFormat('yyyy-MM-dd');
    final startStr = formatter.format(sunday);
    final endStr = formatter.format(sunday.add(const Duration(days: 6)));

    final url = Uri.parse(
      'https://api.fitbit.com/1/user/-/temp/skin/date/$startStr/$endStr.json',
    );

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer ${auth.accessToken}',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final tempList = data['tempSkin'] as List? ?? [];

      final weeklyData = tempList
          .where((e) => e['value']?['nightlyRelative'] != null)
          .map((e) => {
                'date': e['dateTime'],
                'value': (e['value']['nightlyRelative'] as num).toDouble(),
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
