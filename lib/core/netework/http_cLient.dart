abstract class HttpCLient {
  Future<T> get<T>(String url);

  Future<T> post<T>(String url, {Map data});

  Future<T> put<T>(String url, {Map data});

  Future<T> delete<T>(String url);
}
