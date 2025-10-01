import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kotiz_app/core/netework/Http_CLient.dart';
import 'package:kotiz_app/core/utils/secure_storage.dart';

class ApiConfig extends HttpCLient {
  final Dio _dio;
  final SecureStorage _secureStorage = SecureStorage();

  String? _cachedToken;
  DateTime? _tokenExpiry;

  ApiConfig({String? baseUrl})
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl ?? "https://kotiz-back.onrender.com/api/v1/",
          headers: {"Content-Type": "application/json"},
        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          await _attachToken(options);
          handler.next(options);
        },
        onError: (DioException error, handler) async {
          // Si 401, on tente un refresh
          if (error.response?.statusCode == 401) {
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              try {
                // Forcer le refresh du token
                final idTokenResult = await user.getIdTokenResult(true);
                _cachedToken = idTokenResult.token;
                _tokenExpiry = idTokenResult.expirationTime?.subtract(
                  const Duration(minutes: 5),
                );

                // Mettre à jour l'entête Authorization
                error.requestOptions.headers["Authorization"] =
                    "Bearer $_cachedToken";

                // Refaire la requête originale
                final opts = Options(
                  method: error.requestOptions.method,
                  headers: error.requestOptions.headers,
                );
                final cloneResp = await _dio.request(
                  error.requestOptions.path,
                  data: error.requestOptions.data,
                  queryParameters: error.requestOptions.queryParameters,
                  options: opts,
                );
                return handler.resolve(cloneResp);
              } catch (_) {
                // Si le refresh échoue, on rejette l'erreur originale
                return handler.reject(error);
              }
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  // Méthode pour attacher le token si nécessaire
  Future<void> _attachToken(RequestOptions options) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final now = DateTime.now();
    if (_cachedToken == null ||
        _tokenExpiry == null ||
        now.isAfter(_tokenExpiry!)) {
      final idTokenResult = await user.getIdTokenResult(true);
      _cachedToken = idTokenResult.token;
      _tokenExpiry = idTokenResult.expirationTime?.subtract(
        const Duration(minutes: 5),
      );
    }

    if (_cachedToken != null) {
      options.headers["Authorization"] = "Bearer $_cachedToken";
    }
  }

  @override
  Future<T> get<T>(String url) async {
    final response = await _dio.get(url);
    return response.data as T;
  }

  @override
  Future<T> post<T>(
    String url, {
    dynamic data,
    Map<String, String>? headers,
  }) async {
    final response = await _dio.post(
      url,
      data: data,
      options: Options(headers: headers),
    );
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
