 import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:api_buddy/model/request_model.dart';

class RequestProvider extends ChangeNotifier {
  late Box<RequestModel> _requestBox;
  dynamic _lastResponse;
  String _lastResponseTime = '';
  bool _isInitialized = false;

  // Getters to expose private data
  dynamic get lastResponse => _lastResponse;
  String get lastResponseTime => _lastResponseTime;
  bool get isInitialized => _isInitialized;

  /// Get all saved requests from Hive
  List<RequestModel> get requests {
    if (!_isInitialized) {
      print('⚠️  [WARNING] Hive box not initialized yet');
      return [];
    }
    try {
      final list = _requestBox.values.toList();
      print('✅ [SUCCESS] Retrieved ${list.length} requests from Hive');
      return list;
    } catch (e) {
      print('❌ [FAILED] Error getting requests: $e');
      return [];
    }
  }

  RequestProvider() {
    _initializeBox();
  }

  /// Initialize Hive box
  Future<void> _initializeBox() async {
    try {
      _requestBox = await Hive.openBox<RequestModel>('requests');
      _isInitialized = true;
      print('✅ [SUCCESS] Hive box initialized');
      notifyListeners();
    } catch (e) {
      print('❌ [FAILED] Hive box initialization error: $e');
      _isInitialized = false;
    }
  }

  /// Create a new request
  RequestModel createNewRequest() {
    return RequestModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'New Request',
      method: 'GET',
      url: '',
      headers: [],
      auth: null,
      bodyType: 'none',
      body: '',
      params: {},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Save request to Hive
  Future<void> saveRequest(RequestModel request) async {
    try {
      if (!_isInitialized) {
        print('❌ [FAILED] Hive box not initialized');
        return;
      }
      request.updatedAt = DateTime.now();
      await _requestBox.put(request.id, request);
      print('✅ [SUCCESS] Request saved: ${request.name}');
      notifyListeners();
    } catch (e) {
      print('❌ [FAILED] Save request error: $e');
    }
  }

  /// Get all saved requests
  List<RequestModel> getAllRequests() {
    try {
      final requestsList = _requestBox.values.toList();
      print('✅ [SUCCESS] Retrieved ${requestsList.length} requests');
      return requestsList;
    } catch (e) {
      print('❌ [FAILED] Get all requests error: $e');
      return [];
    }
  }

  /// Delete a request
  Future<void> deleteRequest(String requestId) async {
    try {
      if (!_isInitialized) {
        print('❌ [FAILED] Hive box not initialized');
        return;
      }
      await _requestBox.delete(requestId);
      print('✅ [SUCCESS] Request deleted: $requestId');
      notifyListeners();
    } catch (e) {
      print('❌ [FAILED] Delete request error: $e');
    }
  }

  /// Execute HTTP request
  Future<void> executeRequest(
    RequestModel request,
    Map<String, String> environmentVariables,
  ) async {
    try {
      print('\n═══════════════════════════════════════════════════════════');
      print('📤 [REQUEST] Executing: ${request.method} ${request.url}');
      print('═══════════════════════════════════════════════════════════');

      // Replace environment variables in URL
      String url = _replaceVariables(request.url, environmentVariables);
      print('📍 Final URL: $url');

      // Add query parameters
      if (request.params.isNotEmpty) {
        final queryString = request.params.entries
            .map((e) => '${e.key}=${e.value}')
            .join('&');
        url = '$url?$queryString';
        print('📝 Query Parameters: $queryString');
      }

      // Prepare headers
      Map<String, String> headers = {'Content-Type': 'application/json'};
      for (var header in request.headers) {
        if (header.isEnabled) {
          headers[header.key] = _replaceVariables(
            header.value,
            environmentVariables,
          );
        }
      }
      print('🔐 Headers: ${headers.length} headers added');

      // Prepare body
      dynamic body;
      if (request.bodyType != 'none' && request.body.isNotEmpty) {
        try {
          body = jsonEncode(jsonDecode(request.body));
          print('📦 Body: ${body.length} characters');
        } catch (e) {
          body = request.body;
          print('⚠️  Body is plain text (not JSON)');
        }
      }

      // Execute request based on method
      http.Response response;

      switch (request.method.toUpperCase()) {
        case 'GET':
          print('🔄 Making GET request...');
          response = await http.get(Uri.parse(url), headers: headers);
          break;
        case 'POST':
          print('🔄 Making POST request...');
          response = await http.post(Uri.parse(url), headers: headers, body: body);
          break;
        case 'PUT':
          print('🔄 Making PUT request...');
          response = await http.put(Uri.parse(url), headers: headers, body: body);
          break;
        case 'DELETE':
          print('🔄 Making DELETE request...');
          response = await http.delete(Uri.parse(url), headers: headers);
          break;
        case 'PATCH':
          print('🔄 Making PATCH request...');
          response =
              await http.patch(Uri.parse(url), headers: headers, body: body);
          break;
        default:
          print('❌ [FAILED] Unknown HTTP method: ${request.method}');
          return;
      }

      // Handle response
      _handleResponse(response);
      notifyListeners();
    } catch (e) {
      print('❌ [FAILED] Request execution error: $e');
      _lastResponse = {'error': e.toString()};
      _lastResponseTime = DateTime.now().toString();
      notifyListeners();
    }
  }

  /// Handle HTTP response
  void _handleResponse(http.Response response) {
    print('\n═══════════════════════════════════════════════════════════');
    print('📥 [RESPONSE] Status: ${response.statusCode}');
    print('═══════════════════════════════════════════════════════════');

    try {
      // Try to parse as JSON
      dynamic jsonResponse;
      try {
        jsonResponse = jsonDecode(response.body);
      } catch (e) {
        // If not valid JSON, treat as plain text
        jsonResponse = response.body;
        print('⚠️  Response is not JSON (treating as plain text)');
      }

      // Store response based on status code
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('✅ [SUCCESS] Response received successfully');
        _lastResponse = {
          'status': response.statusCode,
          'statusMessage': 'Success',
          'data': jsonResponse,
          'headers': response.headers,
        };

        // Print formatted response
        if (jsonResponse is Map) {
          print('📊 Response Type: Map (Object)');
          print('📊 Keys: ${jsonResponse.keys.toList()}');
        } else if (jsonResponse is List) {
          print('📊 Response Type: List (Array)');
          print('📊 Items: ${jsonResponse.length} items');
          if (jsonResponse.isNotEmpty) {
            print('📊 First item: ${jsonResponse[0]}');
          }
        } else {
          print('📊 Response Type: ${jsonResponse.runtimeType}');
          print('📊 Content: ${jsonResponse.toString().substring(0, 100)}...');
        }
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        print('⚠️  [WARNING] Client Error: ${response.statusCode}');
        _lastResponse = {
          'status': response.statusCode,
          'statusMessage': 'Client Error',
          'error': jsonResponse,
        };
      } else if (response.statusCode >= 500) {
        print('❌ [FAILED] Server Error: ${response.statusCode}');
        _lastResponse = {
          'status': response.statusCode,
          'statusMessage': 'Server Error',
          'error': jsonResponse,
        };
      }

      _lastResponseTime = DateTime.now().toString();

      // Print full response body (truncated if too long)
      String bodyPreview = response.body.length > 500
          ? response.body.substring(0, 500) + '...'
          : response.body;
      print('\n📄 Response Body:\n$bodyPreview');

      print('═══════════════════════════════════════════════════════════\n');
    } catch (e) {
      print('❌ [FAILED] Error parsing response: $e');
      _lastResponse = {
        'error': 'Failed to parse response: $e',
        'rawBody': response.body,
      };
      _lastResponseTime = DateTime.now().toString();
    }
  }

  /// Replace environment variables in string
  String _replaceVariables(
    String text,
    Map<String, String> variables,
  ) {
    String result = text;
    variables.forEach((key, value) {
      result = result.replaceAll('{{$key}}', value);
    });
    return result;
  }
}