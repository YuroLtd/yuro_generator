import 'package:meta/meta.dart';

@immutable
class Retrofit {
  final String? baseUrl;

  const Retrofit({this.baseUrl});
}

class HttpMethod {
  static const String GET = "GET";
  static const String POST = "POST";
  static const String PATCH = "PATCH";
  static const String PUT = "PUT";
  static const String DELETE = "DELETE";
}

@immutable
class _Method {
  final String method;
  final String path;

  const _Method({required this.method, required this.path});
}

@immutable
class GET extends _Method {
  const GET(String path) : super(method: HttpMethod.GET, path: path);
}

@immutable
class POST extends _Method {
  const POST(String path) : super(method: HttpMethod.POST, path: path);
}

@immutable
class PATCH extends _Method {
  const PATCH(String path) : super(method: HttpMethod.PATCH, path: path);
}

@immutable
class PUT extends _Method {
  const PUT(String path) : super(method: HttpMethod.PUT, path: path);
}

@immutable
class DELETE extends _Method {
  const DELETE(String path) : super(method: HttpMethod.DELETE, path: path);
}

@immutable
class Header {
  final String? name;

  const Header([this.name]);
}

@immutable
class Headers {
  final Map<String, dynamic> headers;

  const Headers(this.headers);
}

@immutable
class Extra {
  final String? name;

  const Extra([this.name]);
}

@immutable
class Extras {
  final Map<String, dynamic> extras;

  const Extras(this.extras);
}

@immutable
class Path {
  final String? name;

  const Path([this.name]);
}

/// 只支持基本数据类型int, double, bool, String, num, ffi.Float, ffi.Double
@immutable
class Query {
  final String? name;

  const Query([this.name]);
}

/// 只支持Map<String,dynamic>和实现了toJson()方法的对象
@immutable
class QueryMap {
  const QueryMap();
}

/// 适用于[POST]和[PUT]请求
///
/// 配套的需要使用[Field]和[FieldMap]注解
@immutable
class FormUrlEncoded {
  final contentType = 'application/x-www-form-urlencoded';

  const FormUrlEncoded();
}

/// 适用于[POST]和[PUT]请求
@immutable
class Field {
  final String? name;

  const Field([this.name]);
}

/// 适用于[POST]和[PUT]请求
@immutable
class FieldMap {
  const FieldMap();
}

@immutable
class Multipart {
  final contentType = 'multipart/form-data';

  const Multipart();
}

@immutable
class Part {
  final String? name;

  const Part([this.name]);
}

@immutable
class PartMap {
  const PartMap();
}

/// 只能修饰类型[ProgressCallback]
@immutable
class ReceiveProgress {
  const ReceiveProgress();
}

/// 只能修饰类型[ProgressCallback]
@immutable
class SendProgress {
  const SendProgress();
}

/// 只能修饰类型[CancelToken]
@immutable
class CancelRequest {
  const CancelRequest();
}