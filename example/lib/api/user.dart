import 'dart:ffi';

import 'package:example/api/task.dart';
import 'package:yuro/yuro.dart';
import 'package:yuro_annotation/yuro_annotation.dart';

part 'user.g.dart';

// @Retrofit(baseUrl: 'https://123123/')
@Retrofit()
abstract class UserApi {
  // @GET('a/b/c/{id}')
  // Future getUser(@Path() String id);
  //
  // @GET('a/b/c/{id}')
  // Future<String> getUser1(@Path() String id);
  //
  // @GET('a/b/c/{id}')
  // Stream<String> getUser2(@Path() String id);

  // @GET('a/b/c')
  // Future<List<int?>> getUser3();
  //
  // @GET('a/b/c/')
  // Future<List<int>?> getUser4();
  //
  // @GET('a/b/c/')
  // Future<List<int?>?> getUser5();
  //
  // @GET('a/b/c/')
  // Future<List> getUser6();
  //
  // @GET('a/b/c/')
  // Future<List<Map>> getUser7();
  //
  // @GET('a/b/c/')
  // Future<List<Task>> getUser8();
  //
  // @GET('a/b/c/')
  // Future<Task> getUser9();
  //
  // @GET('a/b/c/')
  // Future<Task?> getUser10();

  // @GET('a/b/c')
  // Future<Task> getUser11(@QueryMap() Task task);

  // @GET('a/b/c')
  // Future<Map<String,String?>> getUser12();
  //
  // @GET('a/b/c')
  // Future<Map<String?,String?>> getUser13();
  //
  // @GET('a/b/c')
  // Future<Map<String,dynamic>> getUser14();
  //
  // @GET('a/b/c')
  // Future<Map> getUser15();

  // @POST('a/b/c')
  // Future<Map> getUser16(@Field() String id, @Field('account') String phone);
  //
  // @POST('a/b/c')
  // @FormUrlEncoded()
  // Future<Map> getUser17(@FieldMap() Map<String, dynamic> params);
  //
  // @GET('a/b/c')
  // @Multipart()
  // Future<Map> getUser18(@Part() String id, @PartMap() Map<String, dynamic> map);

  @GET('a/b/c/')
  Future<Task> getUser19(
    @CancelRequest() CancelToken cancelToken,
    @SendProgress() ProgressCallback sendProgress,
    @ReceiveProgress() ProgressCallback? receivedProgress,
  );

}

class TestImpl {
  TestImpl(this._dio);

  final Dio _dio;

  String? _baseUrl;

  Future<List<int?>> getUser3(id) async {
    final headers = <String, dynamic>{};
    final extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final options = Options(method: 'GET', headers: headers, extra: extra)
        .compose(_dio.options, 'a/b/c/$id', queryParameters: queryParameters)
        .copyWith(baseUrl: _baseUrl ?? _dio.options.baseUrl);
    final response = await _dio.fetch<List<dynamic>>(options);
    return response.data!.cast<int?>();
  }

  Future<List<int>?> getUser4(id) async {
    final headers = <String, dynamic>{};
    final extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final options = Options(method: 'GET', headers: headers, extra: extra)
        .compose(_dio.options, 'a/b/c/$id', queryParameters: queryParameters)
        .copyWith(baseUrl: _baseUrl ?? _dio.options.baseUrl);
    final response = await _dio.fetch<List<dynamic>>(options);
    return response.data?.cast<int>();
  }

  Future<List<int?>?> getUser5(id) async {
    final headers = <String, dynamic>{};
    final extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final options = Options(method: 'GET', headers: headers, extra: extra)
        .compose(_dio.options, 'a/b/c/$id', queryParameters: queryParameters)
        .copyWith(baseUrl: _baseUrl ?? _dio.options.baseUrl);
    final response = await _dio.fetch<List<dynamic>>(options);
    return response.data?.cast<int?>();
  }

  Future<List> getUser6(id) async {
    final headers = <String, dynamic>{};
    final extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final options = Options(method: 'GET', headers: headers, extra: extra)
        .compose(_dio.options, 'a/b/c/$id', queryParameters: queryParameters)
        .copyWith(baseUrl: _baseUrl ?? _dio.options.baseUrl);
    final response = await _dio.fetch<List<dynamic>>(options);
    return response.data!;
  }

  Future<List<Map<dynamic, dynamic>>?> getUser7() async {
    final headers = <String, dynamic>{};
    final extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final options = Options(method: 'GET', headers: headers, extra: extra)
        .compose(_dio.options, 'a/b/c/', queryParameters: queryParameters)
        .copyWith(baseUrl: _baseUrl ?? _dio.options.baseUrl);
    final response = await _dio.fetch<List<dynamic>>(options);
    final result = response.data?.map((e) => e as Map<String, dynamic>).toList();
    return result;
  }

  // Future<Task?> getUser8() async {
  //   final headers = <String, dynamic>{};
  //   final extra = <String, dynamic>{};
  //   final queryParameters = <String, dynamic>{};
  //   final options = Options(method: 'GET', headers: headers, extra: extra)
  //       .compose(_dio.options, 'a/b/c/', queryParameters: queryParameters)
  //       .copyWith(baseUrl: _baseUrl ?? _dio.options.baseUrl);
  //   final response = await _dio.fetch<Map<String,dynamic>>(options);
  //
  //  var result = response.data == null ? null :Task.fromJson(response.data!);
  //  // final result = Task.fromJson(response.data!);
  //   return result;
  // }

  Future<Map<String, dynamic>?> getUser11() async {
    final headers = <String, dynamic>{};
    final extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final options = Options(method: 'GET', headers: headers, extra: extra)
        .compose(_dio.options, 'a/b/c/', queryParameters: queryParameters)
        .copyWith(baseUrl: _baseUrl ?? _dio.options.baseUrl);
    final response = await _dio.fetch<Map<String, dynamic>>(options);
    final result = response.data?.cast<String, dynamic>();
    return result;
  }

  Future<Map<dynamic, dynamic>> getUser18(Map<String, dynamic> maps, String id) async {
    final headers = <String, dynamic>{};
    final extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final data = <String, dynamic>{};

    final options = Options(method: 'GET', headers: headers, extra: extra)
        .compose(_dio.options, 'a/b/c', queryParameters: queryParameters, data: data)
        .copyWith(baseUrl: _baseUrl ?? _dio.options.baseUrl, contentType: 'multipart/form-data');
    final response = await _dio.fetch<Map<String, dynamic>>(options);
    final result = response.data!.cast<dynamic, dynamic>();
    return result;
  }
}
