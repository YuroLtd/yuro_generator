import 'package:example/api/user.dart';
import 'package:yuro/yuro.dart';

class Repository extends YuroLifeCycle {
  late final Dio dio;

  @override
  void onInit() {
    super.onInit();
    var dioClient = DioClient()
      ..baseUrl = ''
      ..connectTimeout = 15.second
    ..build().options
    ;
    dio = dioClient.build();

  }

  late final UserApi userApi = UserApiImpl(dio);
}

Future<void> aa()async{
  return null;
}

void test() async{
  final repository =Repository();
// final a = await repository.userApi.getUser2('extra', uid: 'uid');

  final b = await aa();
}