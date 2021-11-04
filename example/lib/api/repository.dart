import 'package:example/api/user.dart';
import 'package:yuro/yuro.dart';

class Repository extends YuroLifeCycle {
  late final Dio _dioClient;

  @override
  void onInit() {
    super.onInit();
    _dioClient = Dio()
      ..baseUrl = ''
      ..connectTimeout = 15.second;
  }

  late final UserApi userApi = UserApiImpl(_dioClient);
}

Future<void> aa() async {
  return null;
}

void test() async {
  final repository = Repository();
}
