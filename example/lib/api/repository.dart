import 'package:example/api/user.dart';
import 'package:yuro/yuro.dart';

class Repository extends YuroLifeCycle {
  late final DioClient _dioClient;

  @override
  void onInit() {
    super.onInit();
    _dioClient = DioClient()
      ..baseUrl = ''
      ..connectTimeout = 15.second;
  }

  late final UserApi userApi = UserApiImpl(_dioClient.dio);
}

Future<void> aa() async {
  return null;
}

void test() async {
  final repository = Repository();
// final a = await repository.userApi.getUser2('extra', uid: 'uid');

  final b = await aa();
}
