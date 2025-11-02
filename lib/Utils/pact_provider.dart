import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myresolve/Utils/PactCardModel.dart';
import 'package:myresolve/Utils/api_endpoints.dart';
import 'package:http_parser/http_parser.dart';

class PactProvider with ChangeNotifier {
  Future<Map<String, dynamic>> checkInWithImage({required String pactId, required String imagePath, String? comment}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final token = await _storage.read(key: 'token');
      final url = Uri.parse(ApiEndpoints.baseUrl + '/api/checkins/$pactId');
      var request = http.MultipartRequest('POST', url);
      if (token != null) request.headers['Authorization'] = 'Bearer $token';
      // Guess MIME type from file extension
      String? mimeType;
      if (imagePath.endsWith('.png')) {
        mimeType = 'image/png';
      } else if (imagePath.endsWith('.jpg') || imagePath.endsWith('.jpeg')) {
        mimeType = 'image/jpeg';
      } else if (imagePath.endsWith('.gif')) {
        mimeType = 'image/gif';
      }
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imagePath,
        contentType: mimeType != null ? MediaType.parse(mimeType) : null,
      ));
      if (comment != null && comment.isNotEmpty) {
        request.fields['comment'] = comment;
      }
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': response.body};
      } else {
        _error = 'Check-in failed: ' + response.body;
        print(_error);
        String? err = _error;
        _error = null;
        notifyListeners();
        return {'success': false, 'error': err};

      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return {'success': false, 'error': _error};
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
  Future<Map<String, dynamic>> createPact({required String name, required String description, required int totalDays}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final token = await _storage.read(key: 'token');
      final url = Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.pacts);
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'description': description,
          'totalDays': totalDays,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await fetchPacts();
        return {'success': true, 'data': data};
      } else {
        final body = jsonDecode(response.body);
        _error = body['message'] ?? 'Failed to create pact';
        notifyListeners();
        return {'success': false, 'error': _error};
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return {'success': false, 'error': _error};
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
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
  Future<Map<String, dynamic>> verifyCheckin({required String checkinId, required String action}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final token = await _storage.read(key: 'token');
      final url = Uri.parse(ApiEndpoints.baseUrl + '/api/checkins/$checkinId/verify');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'action': action}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchPacts();
        return {'success': true, 'data': response.body};
      } else {
        final body = jsonDecode(response.body);
        print(response.body);
        print(response.statusCode);
        _error = body['message'] ?? 'Failed to verify check-in';
        String? err = _error;
        _error = null;
        notifyListeners();
        return {'success': false, 'error': err};
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return {'success': false, 'error': _error};
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
  PactApiResponse? _pactData;
  bool _loading = false;
  String? _error;
  DateTime? _lastFetchTime;
  static const Duration _cacheValidDuration = Duration(minutes: 5); // Cache valid for 5 minutes

  PactApiResponse? get pactData => _pactData;
  bool get loading => _loading;
  String? get error => _error;
  
  // Check if cached data is still valid
  bool get _isCacheValid {
    if (_lastFetchTime == null || _pactData == null) return false;
    return DateTime.now().difference(_lastFetchTime!) < _cacheValidDuration;
  }

  // Today check-ins state
  List<dynamic>? _todayCheckins;
  bool _todayCheckinsLoading = false;
  String? _todayCheckinsError;

  List<dynamic>? get todayCheckins => _todayCheckins;
  bool get todayCheckinsLoading => _todayCheckinsLoading;
  String? get todayCheckinsError => _todayCheckinsError;

  static const _storage = FlutterSecureStorage();

  Future<void> fetchPacts({bool forceRefresh = false}) async {
    // If cache is valid and not forcing refresh, return early
    if (!forceRefresh && _isCacheValid) {
      return;
    }
    
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
        _lastFetchTime = DateTime.now(); // Update cache timestamp
        _error = null; // Clear error on success
        // print(_pactData?.pacts[1].daysDone);
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

  Future<void> fetchTodayCheckins(String pactId) async {
    _todayCheckinsLoading = true;
    _todayCheckinsError = null;
    notifyListeners();
    try {
      final token = await _storage.read(key: 'token');
      final url = Uri.parse(ApiEndpoints.baseUrl + '/api/pacts/' + pactId + '/today-checkins');
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      });
      if (response.statusCode == 200) {
        _todayCheckins = jsonDecode(response.body) as List<dynamic>;
      } else {
        _todayCheckinsError = 'Failed to fetch today\'s check-ins';
      }
    } catch (e) {
      _todayCheckinsError = e.toString();
    }
    _todayCheckinsLoading = false;
    notifyListeners();
  }

  // Auto-verify check-in using Gemini AI
  Future<Map<String, dynamic>> autoVerifyCheckin({required String checkinId}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    
    try {
      final token = await _storage.read(key: 'token');
      final url = Uri.parse(ApiEndpoints.baseUrl + '/api/checkins/auto-verify/$checkinId');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final body = jsonDecode(response.body);
        _error = body['message'] ?? 'Failed to auto-verify check-in';
        String? err = _error;
        _error = null;
        notifyListeners();
        return {'success': false, 'error': err};
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return {'success': false, 'error': _error};
    } finally {
      _loading = false;
      print(_error);
      notifyListeners();
    }
  }

  // Set Gemini API key
  Future<Map<String, dynamic>> setGeminiApiKey({required String geminiApiKey}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    
    try {
      final token = await _storage.read(key: 'token');
      final url = Uri.parse(ApiEndpoints.baseUrl + '/api/userGeminiKey/set-gemini-key');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'geminiApiKey': geminiApiKey,
        }),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final body = jsonDecode(response.body);
        _error = body['message'] ?? 'Failed to set Gemini API key';
        String? err = _error;
        _error = null;
        notifyListeners();
        return {'success': false, 'error': err};
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return {'success': false, 'error': _error};
    } finally {
      _loading = false;
      print(_error);
      notifyListeners();
    }
  }
}
