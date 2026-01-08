class ApiResponse {
  final String message;
  final int statusCode;
  final dynamic data;
  final String? path;
  final String? timestamp;

  ApiResponse({
    required this.message,
    required this.statusCode,
    this.data,
    this.path,
    this.timestamp,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      message: json['message'],
      statusCode: json['statusCode'],
      data: json['data'],
      path: json['path'],
      timestamp: json['timestamp'],
    );
  }
}
