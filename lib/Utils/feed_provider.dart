import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:myresolve/Utils/api_endpoints.dart';

class FeedModel {
  final String id;
  final String title;
  final String content;
  final String mediaUrl;
  final String category;
  final DateTime createdAt;

  FeedModel({
    required this.id,
    required this.title,
    required this.content,
    required this.mediaUrl,
    required this.category,
    required this.createdAt,
  });

  factory FeedModel.fromJson(Map<String, dynamic> json) {
    return FeedModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      mediaUrl: json['mediaUrl'] ?? '',
      category: json['category'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class FeedProvider with ChangeNotifier {
  List<FeedModel> _feedItems = [];
  bool _isLoading = false;
  String _error = '';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  DateTime? _lastFetchTime;
  static const Duration _cacheValidDuration = Duration(minutes: 10); // Cache valid for 10 minutes

  List<FeedModel> get feedItems => _feedItems;
  bool get isLoading => _isLoading;
  String get error => _error;
  
  // Check if cached data is still valid
  bool get _isCacheValid {
    if (_lastFetchTime == null || _feedItems.isEmpty) return false;
    return DateTime.now().difference(_lastFetchTime!) < _cacheValidDuration;
  }

  Future<void> fetchFeed({bool forceRefresh = false}) async {
    // If cache is valid and not forcing refresh, return early
    if (!forceRefresh && _isCacheValid) {
      return;
    }
    
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final token = await _storage.read(key: 'token');
      print('Feed Provider Token: ${token != null ? 'Found (${token.length} chars)' : 'Not found'}');
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.tipsFeed),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Feed API Response Status: ${response.statusCode}');
      print('Feed API Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        print('Parsed Response Data: $responseData');
        
        // Try different possible response structures
        List<dynamic> feedData = [];
        
        if (responseData is List) {
          // Direct array response
          feedData = responseData;
        } else if (responseData is Map<String, dynamic>) {
          // Object response, check for different data fields
          if (responseData['data'] != null && responseData['data'] is List) {
            feedData = responseData['data'] as List<dynamic>;
          } else if (responseData['tips'] != null && responseData['tips'] is List) {
            feedData = responseData['tips'] as List<dynamic>;
          } else if (responseData['success'] == true && responseData['data'] != null && responseData['data'] is List) {
            feedData = responseData['data'] as List<dynamic>;
          } else {
            _error = responseData['message'] ?? 'No feed data found in response';
            print('API response structure not recognized: $responseData');
          }
        } else {
          _error = 'Unexpected response format';
          print('Response is neither List nor Map: $responseData');
        }
        
        if (feedData.isNotEmpty) {
          _feedItems = feedData.map((item) => FeedModel.fromJson(item)).toList();
          _lastFetchTime = DateTime.now(); // Update cache timestamp\n          print('Successfully loaded ${_feedItems.length} feed items');
        } else if (_error.isEmpty) {
          _error = 'No feed items available';
        }
      } else {
        _error = 'Failed to load feed: ${response.statusCode}';
        print('HTTP Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      _error = 'Error loading feed: $e';
      print('Feed fetch error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String getYouTubeVideoId(String url) {
    // Extract video ID from YouTube URL
    RegExp regExp = RegExp(
      r"(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)([^&\n?#]+)",
      caseSensitive: false,
    );
    Match? match = regExp.firstMatch(url);
    return match?.group(1) ?? '';
  }

  bool isYouTubeUrl(String url) {
    return url.contains('youtube.com') || url.contains('youtu.be');
  }

  String formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  String cleanMarkdownText(String text) {
    // Remove markdown formatting
    return text
        .replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'$1') // Bold
        .replaceAll(RegExp(r'\*([^*]+)\*'), r'$1') // Italic
        .replaceAll(RegExp(r'#{1,6}\s*'), '') // Headers
        .trim();
  }

  String extractTitle(String titleText) {
    // Extract title from "**Title:** content" format
    final match = RegExp(r'\*\*Title:\*\*\s*(.+)', caseSensitive: false).firstMatch(titleText);
    return match?.group(1)?.trim() ?? titleText;
  }

  String extractContent(String contentText) {
    // Extract content from "**Content:** content" format
    final match = RegExp(r'\*\*Content:\*\*\s*(.+)', caseSensitive: false, dotAll: true).firstMatch(contentText);
    return match?.group(1)?.trim() ?? contentText;
  }
}