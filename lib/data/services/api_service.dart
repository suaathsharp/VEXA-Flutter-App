// ──────────────────────────────────────────────────────────────────────────
//  API SERVICE
//  Central HTTP client placeholder.
//  When a REST backend is added, implement real HTTP calls here.
//  All services use this as their HTTP layer instead of calling http directly.
// ──────────────────────────────────────────────────────────────────────────

class ApiService {
  static const String _baseUrl = 'https://api.vexa.lk/v1'; // Future REST API URL

  // ── GET ──────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> get(String endpoint) async {
    // TODO: Replace with real http.get when backend is ready.
    // Example:
    // final response = await http.get(Uri.parse('$_baseUrl/$endpoint'),
    //   headers: {'Authorization': 'Bearer $token'});
    // if (response.statusCode == 200) return jsonDecode(response.body);
    // throw ApiException(response.statusCode, response.body);
    throw UnimplementedError('REST API not yet connected. Use Firebase instead.');
  }

  // ── POST ─────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> post(String endpoint, Map<String, dynamic> body) async {
    // TODO: Replace with real http.post when backend is ready.
    throw UnimplementedError('REST API not yet connected. Use Firebase instead.');
  }

  // ── PUT ──────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> put(String endpoint, Map<String, dynamic> body) async {
    throw UnimplementedError('REST API not yet connected. Use Firebase instead.');
  }

  // ── DELETE ───────────────────────────────────────────────────────────────
  Future<void> delete(String endpoint) async {
    throw UnimplementedError('REST API not yet connected. Use Firebase instead.');
  }

  String get baseUrl => _baseUrl;
}
