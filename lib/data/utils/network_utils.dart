class NetworkUtils {
  static const String baseUrl = "clicktoeat.nasportfolio.com";
  final String path;

  NetworkUtils({required this.path});

  Uri createUrl({String endpoint = ""}) {
    return Uri.https(baseUrl, "$path$endpoint");
  }

  Map<String, String> createAuthorizationHeader(String token) {
    return {
      "authorization": "Bearer $token",
    };
  }
}
