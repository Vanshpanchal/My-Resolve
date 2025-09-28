import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'awesome_snackbar_helper.dart';
import 'api_endpoints.dart';

class UserProfileProvider with ChangeNotifier {
  static const _storage = FlutterSecureStorage();
  bool loading = false;
  bool uploading = false;
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
        print(userProfile);
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

  Future<bool> uploadProfilePicture() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
        requestFullMetadata: false,
      );

      if (image == null) return false;

      // Validate file extension
      final fileExtension = image.path.split('.').last.toLowerCase();
      final validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
      if (!validExtensions.contains(fileExtension)) {
        error = 'Please select a valid image file (jpg, png, gif, webp)';
        notifyListeners();
        return false;
      }

      uploading = true;
      error = null;
      notifyListeners();

      final token = await _storage.read(key: 'token');
      final url = Uri.parse(ApiEndpoints.baseUrl + '/api/users/upload-profile-picture');
      
      final request = http.MultipartRequest('POST', url);
      if (token != null) request.headers['Authorization'] = 'Bearer $token';
      
      // Guess MIME type from file extension (same as checkInWithImage)
      String? mimeType;
      if (image.path.endsWith('.png')) {
        mimeType = 'image/png';
      } else if (image.path.endsWith('.jpg') || image.path.endsWith('.jpeg')) {
        mimeType = 'image/jpeg';
      } else if (image.path.endsWith('.gif')) {
        mimeType = 'image/gif';
      } else if (image.path.endsWith('.webp')) {
        mimeType = 'image/webp';
      }
      
      request.files.add(await http.MultipartFile.fromPath(
        'profilePicture',
        image.path,
        contentType: mimeType != null ? MediaType.parse(mimeType) : null,
      ));
      
      print('Uploading profile picture: ${image.path}, mimeType: $mimeType');

      print('Sending request to: ${url.toString()}');
      print('Request headers: ${request.headers}');
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      print('Response headers: ${response.headers}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        print('Profile picture upload success: $responseData');
        // Update the local userProfile with new profile picture
        if (userProfile != null) {
          userProfile!['profilePicture'] = responseData['profilePictureUrl'] ?? responseData['profilePicture'];
        }
        error = null;
        return true;
      } else {
        error = 'Profile picture upload failed: ${response.body}';
        print(error);
        return false;
      }
    } catch (e) {
      error = e.toString();
      print('Profile picture upload exception: $error');
      return false;
    } finally {
      uploading = false;
      notifyListeners();
    }
  }

  Future<bool> selectAndUploadProfilePicture() async {
    return await uploadProfilePicture();
  }
}
