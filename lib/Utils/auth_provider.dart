import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


import 'package:hive/hive.dart';
import 'package:myresolve/Utils/api_endpoints.dart';
import 'user_model.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? get token => _token;
  static const _storage = FlutterSecureStorage();

  Future<Map<String, dynamic>> login(String email, String password) async {
    EasyLoading.show(status: 'Logging in...');
    final url = Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.login);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    EasyLoading.dismiss();
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      _token = data['data']['token'];
      await _storage.write(key: 'token', value: _token!);
      // Store user details in Hive
      final userJson = data['data']['user'];
      final user = UserModel.fromJson(userJson);
      final userBox = Hive.box<UserModel>('userBox');
      await userBox.clear(); // Only keep one user
      await userBox.add(user);
      notifyListeners();
      return {'success': true};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Login failed'};
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String dob,
    required String countryCode,
    required String mobileNumber,
  }) async {
    EasyLoading.show(status: 'Registering...');
    final url = Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.register);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'dob': dob,
        'countryCode': countryCode,
        'mobileNumber': mobileNumber,
      }),
    );
    EasyLoading.dismiss();
    final data = jsonDecode(response.body);
    if (response.statusCode == 201 && data['success'] == true) {
      EasyLoading.showSuccess('Registration successful');
      return {'success': true};
    } else {
      print(data);
      return {'success': false, 'message': data['message'] ?? 'Registration failed'};
    }
  }

  Future<void> loadToken() async {
  _token = await _storage.read(key: 'token');
  notifyListeners();
  }

  Future<void> logout() async {
  await _storage.delete(key: 'token');
  _token = null;
  notifyListeners();
  }
}
