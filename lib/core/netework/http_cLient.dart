abstract class HttpClient {
  Future<T> get<T>(String url);

  Future<T> post<T>(String url, {Map data});

  Future<T> put<T>(
    String url, {
    Map<String, dynamic> data,
    Map<String, dynamic> headers,
  });

  Future<T> delete<T>(String url);
}
