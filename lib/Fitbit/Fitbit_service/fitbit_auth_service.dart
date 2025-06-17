import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'fitbit_constants.dart';

class FitbitAuthService {
  static final FitbitAuthService _instance = FitbitAuthService._internal();
  factory FitbitAuthService() => _instance;

  String? accessToken;
  String? refreshToken;
  DateTime? tokenExpiry;

  FitbitAuthService._internal() {
    _loadToken();
  }

  // 載入 Token
  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('access_token');
    refreshToken = prefs.getString('refresh_token');
    final expiryString = prefs.getString('token_expiry');
    if (expiryString != null) {
      tokenExpiry = DateTime.tryParse(expiryString);
    }
  }

  // 儲存 Token
  Future<void> _saveToken(String access, String refresh, int expiresInSeconds) async {
    final prefs = await SharedPreferences.getInstance();
    final expiry = DateTime.now().add(Duration(seconds: expiresInSeconds));
    await prefs.setString('access_token', access);
    await prefs.setString('refresh_token', refresh);
    await prefs.setString('token_expiry', expiry.toIso8601String());

    accessToken = access;
    refreshToken = refresh;
    tokenExpiry = expiry;
  }

  // 自動續期
  Future<void> refreshAccessTokenIfNeeded() async {
    if (accessToken == null || refreshToken == null || tokenExpiry == null || DateTime.now().isAfter(tokenExpiry!)) {
      await _refreshAccessToken();
    }
  }

  // 重新刷新 accessToken
  Future<void> _refreshAccessToken() async {
    if (refreshToken == null) return;
    final response = await http.post(
      Uri.parse('https://api.fitbit.com/oauth2/token'),
      headers: {
        'Authorization': 'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken!,
        'client_id': clientId,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _saveToken(data['access_token'], data['refresh_token'], data['expires_in']);
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      await prefs.remove('token_expiry');
      accessToken = null;
      refreshToken = null;
      tokenExpiry = null;
    }
  }

  // 授權登入取得 Token
  Future<bool> handleCallback(String code) async {
    final response = await http.post(
      Uri.parse('https://api.fitbit.com/oauth2/token'),
      headers: {
        'Authorization': 'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'client_id': clientId,
        'grant_type': 'authorization_code',
        'redirect_uri': redirectUri,
        'code': code,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _saveToken(data['access_token'], data['refresh_token'], data['expires_in']);
      return true;
    } else {
      print('交換 Token 失敗: ${response.body}');
      return false;
    }
  }

  // 斷開連結（登出）
Future<void> disconnect() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('access_token');
  await prefs.remove('refresh_token');
  await prefs.remove('token_expiry');
  accessToken = null;
  refreshToken = null;
  tokenExpiry = null;
  print('Fitbit access removed.');
}
}
