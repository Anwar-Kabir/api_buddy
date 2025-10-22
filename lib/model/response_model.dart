class ResponseModel {
  final int statusCode;
  final String statusMessage;
  final String body;
  final Map<String, String> headers;
  final Duration duration;
  final DateTime timestamp;
  final String? error;

  ResponseModel({
    required this.statusCode,
    required this.statusMessage,
    required this.body,
    required this.headers,
    required this.duration,
    required this.timestamp,
    this.error,
  });

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
  bool get isError => statusCode >= 400;
}