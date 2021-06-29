import 'package:yuro/yuro.dart';
import 'package:yuro_generator/yuro_generator.dart';

part 'user.g.dart';

@Retrofit()
abstract class UserApi extends HttpBase with HttpBaseMixin {
  @GET('a/b/c')
  Future<void> getUser();
}


