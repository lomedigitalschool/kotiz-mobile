import 'package:dio/dio.dart';
import 'package:kotiz_app/core/netework/Http_CLient.dart';

class ApiAuth extends HttpCLient {
  final Dio _dio;

  ApiAuth({String? baseUrl})
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl ?? "",
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {"Content-Type": "application/json"},
        ),
      );

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
