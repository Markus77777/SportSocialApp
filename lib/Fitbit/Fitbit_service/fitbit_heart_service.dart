import 'dart:convert';
import 'package:http/http.dart' as http;
import 'fitbit_auth_service.dart';

class FitbitHeartService {
  final FitbitAuthService auth = FitbitAuthService(); 

  
  Future<Map<String, dynamic>?> fetchIntraday({required DateTime date}) async {
    await auth.refreshAccessTokenIfNeeded();
    if (auth.accessToken == null) return null;

    final dateStr = date.toIso8601String().split('T')[0]; // yyyy-MM-dd
    final url = Uri.parse(
      'https://api.fitbit.com/1/user/-/activities/heart/date/$dateStr/1d/1min.json',
    );

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer ${auth.accessToken}',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final dataset = data['activities-heart-intraday']?['dataset'];
      return {
        'type': dataset == null || dataset.isEmpty ? 'empty' : 'intraday',
        'data': dataset ?? [],
      };
    }

    return null;
  }

  // 取得目前的最後一筆心率值（即最新一筆）
  Future<int?> fetchCurrent() async {
    await auth.refreshAccessTokenIfNeeded();
    if (auth.accessToken == null) return null;

    final date = DateTime.now().toIso8601String().split('T')[0];
    final url = Uri.parse(
      'https://api.fitbit.com/1/user/-/activities/heart/date/$date/1d/1min.json',
    );

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer ${auth.accessToken}',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final dataset = data['activities-heart-intraday']?['dataset'];
      if (dataset != null && dataset.isNotEmpty) {
        return dataset.last['value'];
      }
    }

    return null;
  }
}
