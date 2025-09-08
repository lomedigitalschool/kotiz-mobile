import 'package:dio/dio.dart';
import 'package:kotiz_app/core/netework/Http_CLient.dart';
import 'package:kotiz_app/core/utils/secure_storage.dart';

class ApiConfig extends HttpCLient {
  final Dio _dio;
  final SecureStorage _secureStorage = SecureStorage();

  ApiConfig({String? baseUrl})
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl ?? "https://kotiz-back.onrender.com/api/v1",
          headers: {"Content-Type": "application/json"},
        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Routes pour lesquelles on ne met pas le token
          const skipAuth = ["/auth/register", "/auth/login-normal"];

          if (!skipAuth.contains(options.path)) {
            final token = await _secureStorage.getToken();
            if (token != null) {
              options.headers["Authorization"] = "Bearer $token";
            }
          }

          handler.next(options);
        },
      ),
    );
  }

  @override
  Future<T> get<T>(String url) async {
    final response = await _dio.get(url);
    return response.data as T;
  }

  @override
  Future<T> post<T>(String url, {Map? data}) async {
    final response = await _dio.post(url, data: data);
    return response.data as T;
  }

  @override
  Future<T> put<T>(String url, {Map? data}) async {
    final response = await _dio.put(url, data: data);
    return response.data as T;
  }

  @override
  Future<T> delete<T>(String url, {Map<String, String>? headers}) async {
    final response = await _dio.delete(url, options: Options(headers: headers));
    return response.data as T;
  }
}
