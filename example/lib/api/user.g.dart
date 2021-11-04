// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

class UserApi1Impl implements UserApi1 {
  UserApi1Impl(this._dio);

  final Dio _dio;

  @override
  Future<void> test() async {
    final headers = <String, dynamic>{};
    final extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final data = <String, dynamic>{};
    final options = Options(method: 'GET', headers: headers, extra: extra)
        .compose(_dio.options, '/a/b/c',
            queryParameters: queryParameters, data: data)
        .copyWith(baseUrl: _dio.options.baseUrl);
    await _dio.fetch(options);
  }
}

class UserApi2Impl implements UserApi2 {
  UserApi2Impl(this._dio);

  final Dio _dio;

  static const String _baseUrl = 'https://22222';

  @override
  Future<void> test() async {
    final headers = <String, dynamic>{};
    final extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final data = <String, dynamic>{};
    final options = Options(method: 'GET', headers: headers, extra: extra)
        .compose(_dio.options, '/a/b/c',
            queryParameters: queryParameters, data: data)
        .copyWith(baseUrl: _baseUrl);
    await _dio.fetch(options);
  }
}

class UserApi3Impl implements UserApi3 {
  UserApi3Impl(this._dio);

  final Dio _dio;

  static const String _path = '/user3';

  @override
  Future<void> test() async {
    final headers = <String, dynamic>{};
    final extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final data = <String, dynamic>{};
    final options = Options(method: 'GET', headers: headers, extra: extra)
        .compose(_dio.options, '$_path/a/b/c',
            queryParameters: queryParameters, data: data)
        .copyWith(baseUrl: _dio.options.baseUrl);
    await _dio.fetch(options);
  }
}

class UserApiImpl implements UserApi {
  UserApiImpl(this._dio);

  final Dio _dio;

  static const String _baseUrl = 'https://44444';

  static const String _path = '/user4';

  @override
  Future<void> test() async {
    final headers = <String, dynamic>{};
    final extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final data = <String, dynamic>{};
    final options = Options(method: 'GET', headers: headers, extra: extra)
        .compose(_dio.options, '$_path/a/b/c',
            queryParameters: queryParameters, data: data)
        .copyWith(baseUrl: _baseUrl);
    await _dio.fetch(options);
  }

  @override
  Future<Task> getUser19(cancelToken, sendProgress, receivedProgress) async {
    final headers = <String, dynamic>{};
    final extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final data = <String, dynamic>{};
    final options = Options(method: 'GET', headers: headers, extra: extra)
        .compose(_dio.options, '$_path/a/b/c',
            queryParameters: queryParameters, data: data)
        .copyWith(
            baseUrl: _baseUrl,
            cancelToken: cancelToken,
            onSendProgress: sendProgress,
            onReceiveProgress: receivedProgress);
    final response = await _dio.fetch<Map<String, dynamic>>(options);
    return Task.fromJson(response.data!);
  }
}
