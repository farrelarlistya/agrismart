import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';

/// Centralized HTTP client for communicating with the AgriSmart backend API.
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final http.Client _client = http.Client();

  /// Perform a GET request and return the decoded JSON body.
  Future<Map<String, dynamic>> get(String path, {Map<String, String>? queryParams}) async {
    final uri = Uri.parse(ApiConstants.url(path)).replace(queryParameters: queryParams);
    final response = await _client.get(uri, headers: _headers);
    return _handleResponse(response);
  }

  /// Perform a POST request with a JSON body.
  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse(ApiConstants.url(path));
    final response = await _client.post(
      uri,
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  /// Perform a PUT request with a JSON body.
  Future<Map<String, dynamic>> put(String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse(ApiConstants.url(path));
    final response = await _client.put(
      uri,
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  /// Perform a PATCH request with a JSON body.
  Future<Map<String, dynamic>> patch(String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse(ApiConstants.url(path));
    final response = await _client.patch(
      uri,
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  /// Perform a DELETE request.
  Future<Map<String, dynamic>> delete(String path) async {
    final uri = Uri.parse(ApiConstants.url(path));
    final response = await _client.delete(uri, headers: _headers);
    return _handleResponse(response);
  }

  /// Perform a multipart POST request to upload files.
  Future<Map<String, dynamic>> uploadMultipart(String path, {required String fileField, required String filePath}) async {
    final uri = Uri.parse(ApiConstants.url(path));
    final request = http.MultipartRequest('POST', uri);
    
    request.headers.addAll({
      'Accept': 'application/json',
    });

    request.files.add(await http.MultipartFile.fromPath(fileField, filePath));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: body['message'] as String? ?? 'Unknown error',
      );
    }
  }
}

/// Exception thrown when an API call fails.
class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
