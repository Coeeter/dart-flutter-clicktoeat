class DefaultException implements Exception {
  late String error;

  DefaultException({required this.error});

  DefaultException.fromJson(Map<String, dynamic> json) {
    error = json["error"] ?? json["message"];
  }
}
