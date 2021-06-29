library yuro_generator;

export 'retrofit/annotation.dart';
export 'retrofit/retrofit.dart';

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'retrofit/retrofit.dart';

Builder retrofitGenerator(BuilderOptions options) => SharedPartBuilder([RetrofitGenerator()], 'retrofit');
