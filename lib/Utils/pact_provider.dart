import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myresolve/Utils/PactCardModel.dart';
import 'package:myresolve/Utils/api_endpoints.dart';

class PactProvider with ChangeNotifier {
  Future<bool> joinPact(String joinCode) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final token = await _storage.read(key: 'token');
      final url = Uri.parse(ApiEndpoints.baseUrl + '/api/pacts/join/$joinCode');
      final response = await http.post(url, headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      });
      if (response.statusCode == 200) {
        // Optionally refresh pacts after joining
        await fetchPacts();
        return true;
      } else {
        final body = jsonDecode(response.body);
        _error = body['message'] ?? 'Failed to join pact';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
  PactApiResponse? _pactData;
  bool _loading = false;
  String? _error;

  PactApiResponse? get pactData => _pactData;
  bool get loading => _loading;
  String? get error => _error;

  static const _storage = FlutterSecureStorage();

  Future<void> fetchPacts() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final url = Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.pacts);
      final token = await _storage.read(key: 'token');
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      });
      if (response.statusCode == 200) {
        final data = PactApiResponse.fromJson(jsonDecode(response.body));
        _pactData = data;
      } else {
        print(response.body);
        _error = 'Failed to fetch pacts';
      }
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }
}
