import 'dart:convert';
import 'package:http/http.dart' as http;
import 'fitbit_auth_service.dart';

class FitbitSleepService {
final FitbitAuthService auth = FitbitAuthService(); 


  /// 當日總睡眠時間（Duration）
  Future<Duration?> fetchTodaySleepDuration() async {
    return fetchSleepSummary(DateTime.now()).then((summary) {
      final totalMinutes = summary?['totalMinutesAsleep'];
      return totalMinutes != null ? Duration(minutes: totalMinutes) : null;
    });
  }

  /// 根據指定日期取得睡眠摘要（總時間、效率、起訖時間）
  Future<Map<String, dynamic>?> fetchSleepSummary(DateTime date) async {
    await auth.refreshAccessTokenIfNeeded();
    if (auth.accessToken == null) return null;

    final dateStr = _formatDate(date);
    final url = Uri.parse('https://api.fitbit.com/1.2/user/-/sleep/date/$dateStr.json');

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer ${auth.accessToken}',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final summary = data['summary'] ?? {};
      final mainSleep = (data['sleep'] as List?)
          ?.firstWhere((s) => s['isMainSleep'] == true, orElse: () => null);

      return {
        'totalMinutesAsleep': summary['totalMinutesAsleep'],
        'efficiency': mainSleep?['efficiency'],
        'startTime': mainSleep?['startTime'],
        'endTime': mainSleep?['endTime'],
      };
    }

    return null;
  }

  /// 根據指定日期取得睡眠階段（含清醒、REM、淺、深）
  Future<List<Map<String, String>>?> fetchSleepStages(DateTime date) async {
    await auth.refreshAccessTokenIfNeeded();
    if (auth.accessToken == null) return null;

    final dateStr = _formatDate(date);
    final url = Uri.parse('https://api.fitbit.com/1.2/user/-/sleep/date/$dateStr.json');

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer ${auth.accessToken}',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final sleepList = data['sleep'] as List?;
      final mainSleep = sleepList?.firstWhere((s) => s['isMainSleep'] == true, orElse: () => null);
      final levels = mainSleep?['levels']?['data'] as List?;

      if (levels == null || levels.isEmpty) return [];

      return levels.map<Map<String, String>>((entry) {
        final stageMap = {
          'deep': '深層睡眠',
          'light': '淺層睡眠',
          'rem': '快速動眼',
          'wake': '清醒',
        };
        final stage = stageMap[entry['level']] ?? entry['level'];

        final startDateTime = DateTime.parse(entry['dateTime']).toLocal();
        final duration = Duration(seconds: (entry['seconds'] as num).toInt());
        final endDateTime = startDateTime.add(duration);

        return {
          'stage': stage,
          'start': _formatTime(startDateTime),
          'end': _formatTime(endDateTime),
        };
      }).toList();
    }

    return null;
  }

  /// yyyy-MM-dd 格式
  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  /// DateTime 格式轉 HH:mm
  String _formatTime(DateTime dt) {
    final local = dt.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}
