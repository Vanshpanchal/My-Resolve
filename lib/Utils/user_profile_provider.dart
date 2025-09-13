import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'api_endpoints.dart';

class UserProfileProvider with ChangeNotifier {
  static const _storage = FlutterSecureStorage();
  bool loading = false;
  String? error;
  Map<String, dynamic>? userProfile;

  Future<void> fetchUserProfile() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final token = await _storage.read(key: 'token');
      final url = Uri.parse(ApiEndpoints.baseUrl + '/api/users/me');
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      });
      if (response.statusCode == 200) {
        userProfile = jsonDecode(response.body);
        error = null;
      } else {
        error = 'Failed to fetch user profile';
      }
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
