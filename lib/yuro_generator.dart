library yuro_generator;

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'retrofit/retrofit.dart';

Builder retrofitGenerator(BuilderOptions options) => SharedPartBuilder([RetrofitGenerator()], 'retrofit');
