// ignore_for_file: deprecated_member_use

import 'dart:ffi';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:source_gen/source_gen.dart';
import 'package:yuro_annotation/yuro_annotation.dart' as retrofit;

import '../util/string.dart';

part 'retrofit.g.dart';

class RetrofitGenerator extends GeneratorForAnnotation<retrofit.Retrofit> {
  static const _httpMethodTypes = [retrofit.GET, retrofit.POST, retrofit.DELETE, retrofit.PATCH, retrofit.PUT];
  static const _dioField = '_dio';
  static const _baseUrlField = '_baseUrl';
  static const _pathField = '_path';

  static const _baseUrlVar = 'baseUrl';
  static const _headersVar = 'headers';
  static const _extrasVar = 'extra';
  static const _dataVar = 'data';
  static const _contentTypeVar = 'contentType';
  static const _queryParametersVar = 'queryParameters';
  static const _cancelTokenVar = 'cancelToken';
  static const _sendProgressVar = 'onSendProgress';
  static const _receiveProgressVar = 'onReceiveProgress';
  static const _methodVar = 'method';
  static const _pathVar = 'path';
  static const _optionsVar = 'options';
  static const _responseVar = 'response';
  static const _resultVar = 'result';

  @override
  generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError('@Retrofit() cannot be used on non-class objects!', element: element);
    }
    return _implClass(element, annotation);
  }

  String _implClass(ClassElement element, ConstantReader classAnnotation) {
    final classBuilder = Class((classBuilder) => classBuilder
      // 类名
      ..name = '${element.name}Impl'
      // 实现
      ..implements.add(refer(element.name))
      // 成员变量
      ..fields.addAll(_generateFields(classAnnotation))
      // 构造函数
      ..constructors.addAll(_generateConstructors(classAnnotation))
      // 方法
      ..methods.addAll(_generateMethods(classAnnotation, element)));
    return DartFormatter().format('${classBuilder.accept(DartEmitter())}');
  }

  /// 生成成员变量
  List<Field> _generateFields(ConstantReader classAnnotation) {
    final fields = [
      Field((fieldBuilder) => fieldBuilder
        ..name = _dioField
        ..type = refer('Dio')
        ..modifier = FieldModifier.final$)
    ];
    final baseUrl = classAnnotation.peek('baseUrl')?.stringValue;
    if (!baseUrl.isNullOrBlank()) {
      final field = Field((fieldBuilder) => fieldBuilder
        ..name = _baseUrlField
        ..type = refer('String')
        ..static = true
        ..modifier = FieldModifier.constant
        ..assignment = Code("'$baseUrl'"));
      fields.add(field);
    }
    final path = classAnnotation.peek('path')?.stringValue;
    if (!path.isNullOrBlank()) {
      final field = Field((fieldBuilder) => fieldBuilder
        ..name = _pathField
        ..type = refer('String')
        ..static = true
        ..modifier = FieldModifier.constant
        ..assignment = Code("'$path'"));
      fields.add(field);
    }
    return fields;
  }

  /// 生成构造函数
  List<Constructor> _generateConstructors(ConstantReader classAnnotation) => [
        Constructor((constructorBuilder) =>
            constructorBuilder.requiredParameters.add(Parameter((parameterBuilder) => parameterBuilder
              ..name = '_dio'
              ..toThis = true)))
      ];

  /// 生成对应方法
  List<Method> _generateMethods(ConstantReader classAnnotation, ClassElement classElement) => classElement.methods
      .where((method) {
        final httpMethod = method.containAnnotations(_httpMethodTypes);
        final isAbstract = method.isAbstract;
        final isAsyncFuture = method.returnType.isDartAsyncFuture;
        final isAsyncStream = method.returnType.isDartAsyncStream;
        return httpMethod && isAbstract && (isAsyncFuture || isAsyncStream);
      })
      .map((method) => Method((methodBuilder) {
            methodBuilder
              // 方法名称
              ..name = method.displayName
              // 方法覆写标识
              ..annotations.add(const CodeExpression(Code('override')))
              // 方法异步标识
              ..modifier = method.returnType.isDartAsyncFuture ? MethodModifier.async : MethodModifier.asyncStar
              // 方法返回类型
              ..returns = refer(method.type.returnType.getDisplayString(withNullability: true))
              // 方法参数
              ..types.addAll(method.typeParameters.map((e) => refer(e.name)))
              // 必须参数
              ..requiredParameters.addAll(method.parameters
                  .where((element) => element.isRequiredPositional)
                  .map((parameter) => Parameter((parameterBuilder) => parameterBuilder
                    ..name = parameter.name
                    ..named = parameter.isNamed)))
              // 可选参数
              ..optionalParameters.addAll(method.parameters
                  .where((element) => element.isOptional || element.isRequiredNamed)
                  .map((parameter) => Parameter((parameterBuilder) {
                        final nullability = parameter.type.nullabilitySuffix == NullabilitySuffix.none;
                        parameterBuilder
                          ..name = parameter.name
                          ..named = parameter.isNamed
                          ..required = parameter.isNamed && nullability && !parameter.hasDefaultValue
                          ..defaultTo = parameter.defaultValueCode == null ? null : Code(parameter.defaultValueCode!);
                      })));
            // 方法体
            final bodyBlocks = <Code>[];
            final httpMethod = method.getFirstAnnotation(_httpMethodTypes);
            if (httpMethod == null) {
              throw InvalidGenerationSourceError(
                'The method must have an annotation similar to @GET or other!',
                element: method,
              );
            }
            // @Header,@Headers注解
            bodyBlocks.add(_generateHeaders(method));
            // @Extra,@Extras
            bodyBlocks.add(_generateExtras(method));
            // @Query,@QueryMap注解
            bodyBlocks.addAll(_generateQueryMap(httpMethod, method));
            // @Filed、@FiledMap、@Part、@PartMap
            bodyBlocks.addAll(_generateData(method));
            //
            final optionsArgs = <String, Expression>{
              _methodVar: literal(httpMethod.peek('method')?.stringValue),
              _headersVar: refer(_headersVar),
              _extrasVar: refer(_extrasVar),
            };
            final composeArgs = <String, Expression>{
              _baseUrlVar: _generateBaseUrl(classAnnotation),
              _pathVar: _generatePath(classAnnotation, httpMethod, method),
              _queryParametersVar: refer(_queryParametersVar),
            };
            // @FormUrlEncoded @Multipart
            _parseContentType(method, composeArgs);
            // @CancelRequest @SendProgress @ReceiveProgress
            _parseOtherRequestAnnotation(method, composeArgs);

            bodyBlocks.add(_generateRequestOptions(optionsArgs, composeArgs));
            //
            final returnType = method.returnType.genericOf();
            if (returnType != null) {
              bodyBlocks.addAll(_generateRequest(method, returnType));
            } else {
              throw InvalidGenerationSourceError('Return type is ${returnType.toString()}!', element: method);
            }
            methodBuilder.body = Block.of(bodyBlocks);
          }))
      .toList();

  /// 解析 @FormUrlEncoded @Multipart 获取contentType
  void _parseContentType(MethodElement method, Map<String, Expression> composeArgs) {
    final formUrlEncodedAnnotation = method.getAnnotation(retrofit.FormUrlEncoded);
    final multipartAnnotation = method.getAnnotation(retrofit.Multipart);
    if (multipartAnnotation != null) {
      composeArgs[_dataVar] = refer('FormData').property('fromMap').call([refer(_dataVar)]);
    } else {
      composeArgs[_dataVar] = refer(_dataVar);
    }
    final contentType = (formUrlEncodedAnnotation ?? multipartAnnotation)?.peek('contentType')?.stringValue;
    if (contentType != null) {
      composeArgs[_contentTypeVar] = literalString(contentType);
    }
  }

  /// 解析@CancelRequest @SendProgress @ReceiveProgress
  void _parseOtherRequestAnnotation(MethodElement method, Map<String, Expression> composeArgs) {
    final cancelToken = method.getFirstParameterAnnotation(retrofit.CancelRequest);
    if (cancelToken != null) {
      final nullable = cancelToken.item1.type.isNullable;
      if (cancelToken.item1.type.toString() == 'CancelToken${nullable ? '?' : ''}') {
        composeArgs[_cancelTokenVar] = refer(cancelToken.item1.displayName);
      } else {
        throw InvalidGenerationSourceError(
          '@CancelRequest can only be used for parameters whose type is `CancelToken`!',
          element: method,
        );
      }
    }
    final sendProgress = method.getFirstParameterAnnotation(retrofit.SendProgress);
    if (sendProgress != null) {
      if (sendProgress.item1.type.getDisplayString(withNullability: false) == 'void Function(int, int)') {
        composeArgs[_sendProgressVar] = refer(sendProgress.item1.displayName);
      } else {
        throw InvalidGenerationSourceError(
          '@SendProgress can only be used for parameters whose type is `ProgressCallback`!',
          element: method,
        );
      }
    }

    final receiveProgress = method.getFirstParameterAnnotation(retrofit.ReceiveProgress);
    if (receiveProgress != null) {
      if (receiveProgress.item1.type.getDisplayString(withNullability: false) == 'void Function(int, int)') {
        composeArgs[_receiveProgressVar] = refer(receiveProgress.item1.displayName);
      } else {
        throw InvalidGenerationSourceError(
          '@ReceiveProgress can only be used for parameters whose type is `ProgressCallback`!',
          element: method,
        );
      }
    }
  }

  /// 解析@Headers和@Header生成代码
  Code _generateHeaders(MethodElement method) {
    // 从@Headers注解中解析出请求头
    final headersAnnotation = method.getAnnotation(retrofit.Headers);
    final headersMap = headersAnnotation?.peek('headers')?.mapValue ?? {};
    final headers = headersMap.map((k, v) {
      final key = k?.toStringValue();
      // 注解已定义为非空,无实际意义,可保证生成的map为非空的key
      if (key == null) throw InvalidGenerationSourceError('Only `String` keys are supported!', element: method);
      final value = v?.toStringValue() ?? v?.toIntValue() ?? v?.toDoubleValue() ?? v?.toBoolValue();
      return MapEntry(key, literal(value));
    });
    // 从方法参数@Header注解中解析出请求头
    final headerAnnotation = method.getParameterAnnotations(retrofit.Header);
    final headersInParams = headerAnnotation.map((k, v) {
      return MapEntry(v.peek('name')?.stringValue ?? k.displayName, refer(k.displayName));
    });
    headers.addAll(headersInParams);
    final mapExpression = literalMap(
      headers.map((k, v) => MapEntry(literalString(k), v)),
      refer('String'),
      refer('dynamic'),
    );
    return mapExpression.assignFinal(_headersVar).statement;
  }

  /// 解析@Extra和@Extras生成代码
  Code _generateExtras(MethodElement method) {
    final extrasAnnotation = method.getAnnotation(retrofit.Extras);
    final extrasMap = extrasAnnotation?.peek('extras')?.mapValue ?? {};
    final extras = extrasMap.map((k, v) {
      final key = k?.toStringValue();
      if (key == null) throw InvalidGenerationSourceError('Only `String` keys are supported!', element: method);
      final value = v?.toStringValue() ?? v?.toIntValue() ?? v?.toDoubleValue() ?? v?.toBoolValue();
      return MapEntry(key, literal(value));
    });
    //
    final extraAnnotation = method.getParameterAnnotations(retrofit.Extra);
    final extrasInParams = extraAnnotation.map((k, v) {
      return MapEntry(v.peek('name')?.stringValue ?? k.displayName, refer(k.displayName));
    });
    extras.addAll(extrasInParams);
    final mapExpression = literalMap(
      extras.map((k, v) => MapEntry(literalString(k), v)),
      refer('String'),
      refer('dynamic'),
    );
    return mapExpression.assignFinal(_extrasVar).statement;
  }

  /// 解析@Query和@QueryMap生成代码
  List<Code> _generateQueryMap(ConstantReader httpMethod, MethodElement method) {
    final blocks = <Code>[];
    // @Query
    final queryAnnotation = method.getParameterAnnotations(retrofit.Query);
    final queryParameters = queryAnnotation.map((k, v) {
      if (k.type.isBasicType || k.type.isDartCoreList) {
        return MapEntry(literalString(v.peek('name')?.stringValue ?? k.displayName), refer(k.displayName));
      } else {
        throw InvalidGenerationSourceError(
          'Only supports int, double, bool, String, num, ffi.Float, ffi.Double, List!',
          element: method,
        );
      }
    });
    blocks.add(literalMap(queryParameters.map((k, v) => MapEntry(k, v)), refer('String'), refer('dynamic'))
        .assignFinal(_queryParametersVar)
        .statement);
    // @QueryMap
    final queryMapAnnotation = method.getParameterAnnotations(retrofit.QueryMap);
    queryMapAnnotation.keys.forEach((element) {
      final displayName = element.displayName;
      final nullable = element.type.nullabilitySuffix == NullabilitySuffix.question;
      late Expression value;
      if (!element.type.isBasicType && !element.type.isCollectionType) {
        final cle = element.type.element2 as ClassElement;
        if (!cle.hasMethod('toJson')) {
          throw InvalidGenerationSourceError(
            'The `toJson()` method must be implemented by class `${cle.displayName}`!',
            element: method,
          );
        }
        value = nullable
            ? refer(displayName).nullSafeProperty('toJson').call([])
            : refer(displayName).property('toJson').call([]);
      } else if (element.type.isDartCoreMap) {
        value = refer(displayName);
      } else {
        throw InvalidGenerationSourceError('`${element.type.toString()}` not supported!', element: method);
      }
      final emitter = DartEmitter();
      final buffer = StringBuffer();
      value.accept(emitter, buffer);
      if (nullable) refer(' ?? <String, dynamic>{}').accept(emitter, buffer);

      final expression = refer(buffer.toString());
      blocks.add(refer('$_queryParametersVar.addAll').call([expression]).statement);
    });
    if (httpMethod.peek('method')?.stringValue == retrofit.HttpMethod.GET) {
      blocks.add(refer(_queryParametersVar).property('removeWhere').call([refer('(k, v) => v == null')]).statement);
    }
    return blocks;
  }

  /// 解析@Filed、@FiledMap、@Part、@PartMap生成代码
  List<Code> _generateData(MethodElement method) {
    final blocks = <Code>[];
    // 如果方法被@Multipart注解,则只解析@Part、@PartMap
    if (method.containAnnotation(retrofit.Multipart)) {
      // @Part
      final partAnnotation = method.getParameterAnnotations(retrofit.Part);
      final partParameters = partAnnotation.map((k, v) {
        return MapEntry(literalString(v.peek('name')?.stringValue ?? k.displayName), refer(k.displayName));
      });
      blocks.add(literalMap(partParameters.map((k, v) => MapEntry(k, v)), refer('String'), refer('dynamic'))
          .assignFinal(_dataVar)
          .statement);
      // @PartMap
      final partMapAnnotation = method.getParameterAnnotations(retrofit.PartMap);
      partMapAnnotation.keys.forEach((element) {
        final displayName = element.displayName;
        final nullable = element.type.nullabilitySuffix == NullabilitySuffix.question;
        late Expression value;
        if (!element.type.isBasicType && !element.type.isCollectionType) {
          final cle = element.type.element2 as ClassElement;
          if (!cle.hasMethod('toJson')) {
            throw InvalidGenerationSourceError(
              'The `toJson()` method must be implemented by class `${cle.displayName}`!',
              element: method,
            );
          }
          value = nullable
              ? refer(displayName).nullSafeProperty('toJson').call([])
              : refer(displayName).property('toJson').call([]);
        } else {
          value = refer(displayName);
        }
        final emitter = DartEmitter();
        final buffer = StringBuffer();
        value.accept(emitter, buffer);
        if (nullable) refer(' ?? <String, dynamic>{}').accept(emitter, buffer);

        final expression = refer(buffer.toString());
        blocks.add(refer('$_dataVar.addAll').call([expression]).statement);
      });
    } else {
      // @Field
      final filedAnnotation = method.getParameterAnnotations(retrofit.Field);
      final filedParameters = filedAnnotation.map((k, v) {
        if (k.type.isBasicType || k.type.isDartCoreList) {
          return MapEntry(literalString(v.peek('name')?.stringValue ?? k.displayName), refer(k.displayName));
        } else {
          throw InvalidGenerationSourceError(
            ' Only supports int, double, bool, String, num, ffi.Float, ffi.Double, List!',
            element: method,
          );
        }
      });
      blocks.add(literalMap(filedParameters.map((k, v) => MapEntry(k, v)), refer('String'), refer('dynamic'))
          .assignFinal(_dataVar)
          .statement);
      // @FieldMap
      final fieldMapMapAnnotation = method.getParameterAnnotations(retrofit.FieldMap);
      fieldMapMapAnnotation.keys.forEach((element) {
        final displayName = element.displayName;
        final nullable = element.type.nullabilitySuffix == NullabilitySuffix.question;
        late Expression value;
        if (!element.type.isBasicType && !element.type.isCollectionType) {
          final cle = element.type.element2 as ClassElement;
          if (!cle.hasMethod('toJson')) {
            throw InvalidGenerationSourceError(
              'The `toJson()` method must be implemented by class `${cle.displayName}`!',
              element: method,
            );
          }
          value = nullable
              ? refer(displayName).nullSafeProperty('toJson').call([])
              : refer(displayName).property('toJson').call([]);
        } else if (element.type.isDartCoreMap) {
          value = refer(displayName);
        } else {
          throw InvalidGenerationSourceError(
            '`${element.type.toString()}` is not supported by @FieldMap!',
            element: method,
          );
        }
        final emitter = DartEmitter();
        final buffer = StringBuffer();
        value.accept(emitter, buffer);
        if (nullable) refer(' ?? <String, dynamic>{}').accept(emitter, buffer);

        final expression = refer(buffer.toString());
        blocks.add(refer('$_dataVar.addAll').call([expression]).statement);
      });
    }

    return blocks;
  }

  /// 解析@Path生成代码
  Expression _generateBaseUrl(ConstantReader classAnnotation) {
    final hasBaseUrlField = (classAnnotation.peek('baseUrl')?.stringValue).isNullOrBlank();
    return !hasBaseUrlField ? refer(_baseUrlField) : refer(_dioField).property('options').property('baseUrl');
  }

  /// 解析@Path生成代码
  Expression _generatePath(ConstantReader classAnnotation, ConstantReader httpMethod, MethodElement method) {
    String? path = httpMethod.peek('path')?.stringValue;
    final pathAnnotations = method.getParameterAnnotations(retrofit.Path);
    pathAnnotations.forEach((key, value) {
      final replaceStr = value.peek('name')?.stringValue ?? key.displayName;
      path = path?.replaceFirst('{$replaceStr}', '\$${key.displayName}');
    });
    final hasPathField = (classAnnotation.peek('path')?.stringValue).isNullOrBlank();
    return !hasPathField ? literal('\$$_pathField$path') : literal(path);
  }

  /// 生成options变量
  Code _generateRequestOptions(Map<String, Expression> optionsArgs, Map<String, Expression> composeArgs) {
    final path = composeArgs.remove(_pathVar)!;
    final baseUrl = composeArgs.remove(_baseUrlVar)!;

    final copyWithTypeArguments = <String, Expression>{_baseUrlVar: baseUrl};
    final contentType = composeArgs.remove(_contentTypeVar);
    if (contentType != null) copyWithTypeArguments[_contentTypeVar] = contentType;

    final cancelToken = composeArgs.remove(_cancelTokenVar);
    if (cancelToken != null) copyWithTypeArguments[_cancelTokenVar] = cancelToken;

    final sendProgress = composeArgs.remove(_sendProgressVar);
    if (sendProgress != null) copyWithTypeArguments[_sendProgressVar] = sendProgress;

    final receiveProgress = composeArgs.remove(_receiveProgressVar);
    if (receiveProgress != null) copyWithTypeArguments[_receiveProgressVar] = receiveProgress;

    return refer('Options')
        .newInstance([], optionsArgs)
        .property('compose')
        .call([refer(_dioField).property('options'), path], composeArgs)
        .property('copyWith')
        .call([], copyWithTypeArguments)
        .assignFinal(_optionsVar)
        .statement;
  }

  /// 生成请求及返回代码
  List<Code> _generateRequest(MethodElement method, DartType returnType) {
    // void
    if (returnType.isVoid) {
      return [
        refer('await $_dioField.fetch').call([refer(_optionsVar)]).statement
      ];
    }

    final returnAsyncStream = method.returnType.isDartAsyncStream;
    // dynamic
    if (returnType.isDynamic) {
      return [
        refer('await $_dioField.fetch').call([refer(_optionsVar)]).assignFinal(_responseVar).statement,
        refer('$_responseVar.data').returnedIf(asyncStream: returnAsyncStream).statement
      ];
    }
    // int、double、 bool、 String、num、ffi.Float、ffi.Double
    if (returnType.isBasicType) {
      return [
        refer('await $_dioField.fetch').call([refer(_optionsVar)]).assignFinal(_responseVar).statement,
        refer('$_responseVar.data as ${returnType.getDisplayString(withNullability: returnType.isNullable)}')
            .returnedIf(asyncStream: returnAsyncStream)
            .statement,
      ];
    }

    // Map
    if (returnType.isDartCoreMap) {
      final types = returnType.genericListOf()!;
      if (types.length != 2) {
        // map的泛型长度错误, 硬性检查
        throw InvalidGenerationSourceError('The generic length of `Map` is ${types.length}!', element: method);
      }
      return [
        refer('await $_dioField.fetch')
            .call([refer(_optionsVar)], {}, [refer('Map<String,dynamic>')])
            .assignFinal(_responseVar)
            .statement,
        refer('$_responseVar.data')
            .propertyIf('cast', nullable: returnType.isNullable)
            .call([], {}, [
              refer(types[0].getDisplayString(withNullability: true)),
              refer(types[1].getDisplayString(withNullability: true))
            ])
            .assignFinal(_resultVar)
            .statement,
        Code('${returnAsyncStream ? 'yield' : 'return'} $_resultVar;')
      ];
    }
    // List
    final codes = <Code>[];
    if (returnType.isDartCoreList) {
      final returnInnerType = returnType.genericOf();
      codes.addAll([
        refer('await $_dioField.fetch')
            .call([refer(_optionsVar)], {}, [refer('List<dynamic>')])
            .assignFinal(_responseVar)
            .statement,
      ]);
      if (returnInnerType == null) {
        throw InvalidGenerationSourceError('The generic of `${returnType.toString()}` is null!', element: method);
      }

      if (returnInnerType.isDynamic) {
        codes.add(refer('$_responseVar.data')
            .returnedIf(nullable: returnType.isNullable, asyncStream: returnAsyncStream)
            .statement);
      } else if (returnInnerType.isBasicType) {
        codes.addAll([
          refer('$_responseVar.data')
              .propertyIf('cast', nullable: returnType.isNullable)
              .call([], {}, [refer(returnInnerType.toString())])
              .assignFinal(_resultVar)
              .statement,
          Code('${returnAsyncStream ? 'yield' : 'return'} $_resultVar;')
        ]);
      } else if (returnInnerType.isDartCoreMap) {
        codes.addAll([
          refer('$_responseVar.data')
              .propertyIf('map', nullable: returnType.isNullable)
              .call([refer('(i) => i as Map<String,dynamic>')])
              .property('toList')
              .call([])
              .assignFinal(_resultVar)
              .statement,
          Code('${returnAsyncStream ? 'yield' : 'return'} $_resultVar;')
        ]);
      } else {
        final displayName = returnInnerType.getDisplayString(withNullability: false);
        final cle = returnInnerType.element2 as ClassElement;
        if (!cle.hasConstructor('fromJson')) {
          throw InvalidGenerationSourceError(
              'The constructor method `fromJson()` must be implemented by class `${cle.name}`!',
              element: method);
        }
        codes.addAll([
          refer('$_responseVar.data')
              .propertyIf('map', nullable: returnType.isNullable)
              .call([refer('(i) => $displayName.fromJson(i as Map<String,dynamic>)')])
              .property('toList')
              .call([])
              .assignFinal(_resultVar)
              .statement,
          Code('${returnAsyncStream ? 'yield' : 'return'} $_resultVar;')
        ]);
      }
      return codes;
    }

    //
    final displayName = returnType.getDisplayString(withNullability: false);
    final cle = returnType.element2 as ClassElement;
    if (!cle.hasConstructor('fromJson')) {
      throw InvalidGenerationSourceError(
          'The constructor method `fromJson()` must be implemented by class `${cle.name}`!',
          element: method);
    }
    codes.add(refer('await $_dioField.fetch').call([refer(_optionsVar)]).assignFinal(_responseVar).statement);
    if (returnType.isNullable) {
      codes.add(refer('response.data == null ? null :$displayName.fromJson(response.data!)')
          .returnedIf(asyncStream: returnAsyncStream)
          .statement);
    } else {
      codes.add(refer('$displayName.fromJson(response.data!)').returnedIf(asyncStream: returnAsyncStream).statement);
    }
    return codes;
  }
}
