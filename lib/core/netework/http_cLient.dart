abstract class HttpClient {
abstract class HttpClient {
  Future<T> get<T>(String url);

  Future<T> post<T>(String url, {dynamic data, Map<String, String>? headers});

  Future<T> put<T>(String url, {Map? data});

  Future<T> delete<T>(String url, {Map<String, String>? headers});
}