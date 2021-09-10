import 'package:flutter_test/flutter_test.dart';

void main() async {
  test('description', () {
    List list = [1, 2, null];

    List<int?> list2 = list.cast<int?>();
    print(list2);
  });
}
