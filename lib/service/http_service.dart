import 'package:api_buddy/model/request_model.dart';
import 'package:api_buddy/model/response_model.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; 
class HttpService {
  final Dio _dio = Dio();
  final secureStorage = const FlutterSecureStorage();

  HttpService() {
    _dio.options = BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      validateStatus: (_) => true, // Accept all status codes
    );
  }

  Future<ResponseModel> executeRequest(
    RequestModel request, {
    Map<String, String> environmentVariables = const {},
  }) async {
    try {
      final stopwatch = Stopwatch()..start();

      // Replace environment variables in URL
      String url = _replaceVariables(request.url, environmentVariables);

      // Build headers
      final headers = _buildHeaders(request, environmentVariables);

      // Build query parameters
      final params = _buildParams(request.params, environmentVariables);

      // Build request body
      final body = _buildBody(request, environmentVariables);

      // Make request
      late Response response;
      switch (request.method.toUpperCase()) {
        case 'GET':
          response = await _dio.get(
            url,
            queryParameters: params,
            options: Options(headers: headers),
          );
          break;
        case 'POST':
          response = await _dio.post(
            url,
            data: body,
            queryParameters: params,
            options: Options(headers: headers),
          );
          break;
        case 'PUT':
          response = await _dio.put(
            url,
            data: body,
            queryParameters: params,
            options: Options(headers: headers),
          );
          break;
        case 'DELETE':
          response = await _dio.delete(
            url,
            data: body,
            queryParameters: params,
            options: Options(headers: headers),
          );
          break;
        case 'PATCH':
          response = await _dio.patch(
            url,
            data: body,
            queryParameters: params,
            options: Options(headers: headers),
          );
          break;
        case 'HEAD':
          response = await _dio.head(
            url,
            queryParameters: params,
            options: Options(headers: headers),
          );
          break;
        default:
          throw Exception('Unsupported HTTP method: ${request.method}');
      }

      stopwatch.stop();

      return ResponseModel(
        statusCode: response.statusCode ?? 0,
        statusMessage: response.statusMessage ?? '',
        body: _formatResponse(response.data),
        headers: Map<String, String>.from(response.headers.map),
        duration: stopwatch.elapsed,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      return ResponseModel(
        statusCode: 0,
        statusMessage: 'Error',
        body: '',
        headers: {},
        duration: Duration.zero,
        timestamp: DateTime.now(),
        error: e.toString(),
      );
    }
  }

  Map<String, dynamic> _buildHeaders(
    RequestModel request,
    Map<String, String> envVars,
  ) {
    final headers = <String, dynamic>{};

    // Add default headers
    headers['Content-Type'] = _getContentType(request.bodyType);

    // Add custom headers
    for (var header in request.headers) {
      if (header.isEnabled) {
        headers[header.key] = _replaceVariables(header.value, envVars);
      }
    }

    // Add authentication
    if (request.auth != null && request.auth!.type != 'none') {
      final authHeader = _buildAuthHeader(request.auth!, envVars);
      if (authHeader.isNotEmpty) {
        headers['Authorization'] = authHeader;
      }
    }

    return headers;
  }

  String _buildAuthHeader(AuthModel auth, Map<String, String> envVars) {
    switch (auth.type.toLowerCase()) {
      case 'basic':
        final credentials = '${auth.username}:${auth.password}';
        final encoded = base64Encode(utf8.encode(credentials));
        return 'Basic $encoded';
      case 'bearer':
        final token = _replaceVariables(auth.token, envVars);
        return 'Bearer $token';
      default:
        return '';
    }
  }

  dynamic _buildBody(RequestModel request, Map<String, String> envVars) {
    if (request.bodyType == 'none' || request.body.isEmpty) {
      return null;
    }

    final bodyContent = _replaceVariables(request.body, envVars);

    switch (request.bodyType.toLowerCase()) {
      case 'raw':
        try {
          // Try to parse as JSON
          return jsonDecode(bodyContent);
        } catch (e) {
          // Return as string if not valid JSON
          return bodyContent;
        }

      case 'formdata':
        final formData = FormData();
        final lines = bodyContent.split('\n');
        for (var line in lines) {
          final parts = line.split(':');
          if (parts.length == 2) {
            formData.fields.add(MapEntry(parts[0].trim(), parts[1].trim()));
          }
        }
        return formData;

      case 'x-www-form-urlencoded':
        final params = <String, dynamic>{};
        final pairs = bodyContent.split('&');
        for (var pair in pairs) {
          final kv = pair.split('=');
          if (kv.length == 2) {
            params[kv[0]] = Uri.decodeComponent(kv[1]);
          }
        }
        return params;

      default:
        return bodyContent;
    }
  }

  Map<String, dynamic> _buildParams(
    Map<String, String> params,
    Map<String, String> envVars,
  ) {
    return params.map(
      (key, value) => MapEntry(
        key,
        _replaceVariables(value, envVars),
      ),
    );
  }

  String _replaceVariables(String text, Map<String, String> variables) {
    String result = text;
    variables.forEach((key, value) {
      result = result.replaceAll('{{$key}}', value);
    });
    return result;
  }

  String _getContentType(String bodyType) {
    switch (bodyType.toLowerCase()) {
      case 'formdata':
        return 'multipart/form-data';
      case 'x-www-form-urlencoded':
        return 'application/x-www-form-urlencoded';
      case 'raw':
        return 'application/json';
      default:
        return 'application/json';
    }
  }

  String _formatResponse(dynamic data) {
    if (data == null) return '';
    if (data is String) return data;
    try {
      if (data is Map || data is List) {
        return jsonEncode(data);
      }
    } catch (e) {
      return data.toString();
    }
    return data.toString();
  }
}