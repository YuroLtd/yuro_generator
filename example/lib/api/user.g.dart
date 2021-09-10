// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

class UserApiImpl implements UserApi {
  UserApiImpl(this._dio);

  final Dio _dio;

  String? _baseUrl;

  @override
  Future<Task> getUser19(cancelToken, sendProgress, receivedProgress) async {
    final headers = <String, dynamic>{};
    final extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final data = <String, dynamic>{};
    final options = Options(method: 'GET', headers: headers, extra: extra)
        .compose(_dio.options, 'a/b/c/', queryParameters: queryParameters, data: data)
        .copyWith(
            baseUrl: _baseUrl ?? _dio.options.baseUrl,
            cancelToken: cancelToken,
            onSendProgress: sendProgress,
            onReceiveProgress: receivedProgress);
    final response = await _dio.fetch<Map<String, dynamic>>(options);
    return Task.fromJson(response.data!);
  }
}
