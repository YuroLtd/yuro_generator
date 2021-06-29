import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:source_gen/source_gen.dart';

import 'annotation.dart' as retrofit;

class RetrofitGenerator extends GeneratorForAnnotation<retrofit.Retrofit> {
  static const _methodAnnotations = [retrofit.GET, retrofit.POST, retrofit.DELETE, retrofit.PATCH, retrofit.PUT];

  late retrofit.Retrofit _retrofit;

  @override
  generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError('@Retrofit() cannot be used on non-class objects!', element: element);
    }
    return _implClass(element, annotation);
  }

  String _implClass(ClassElement element, ConstantReader annotation) {
    var className = element.name;
    _retrofit = retrofit.Retrofit();
    final classBuilder = Class((c) => c
      ..name = '${className}Impl'
      ..extend = refer(className)
      ..methods.addAll(_parseMethods(element)));
    return DartFormatter().format('${classBuilder.accept(DartEmitter())}');
  }

  /// 解析方法
  Iterable<Method> _parseMethods(ClassElement classElement) => (<MethodElement>[]
        ..addAll(classElement.methods)
        ..addAll(classElement.mixins.expand((element) => element.methods)))
      .where((method) =>
          _getMethodAnnotation(method) != null &&
          method.isAbstract &&
          (method.returnType.isDartAsyncFuture || method.returnType.isDartAsyncStream))
      .map((method) => _generateMethod(method)!);

  /// 获取[MethodElement]的第一个注解
  ConstantReader? _getMethodAnnotation(MethodElement method) {
    for (final type in _methodAnnotations) {
      final annotation = _typeChecker(type).firstAnnotationOf(method, throwOnUnresolved: false);
      if (annotation != null) return ConstantReader(annotation);
    }
    return null;
  }

  /// 生成方法
  Method? _generateMethod(MethodElement me) {
    final annotation = _getMethodAnnotation(me);
    if (annotation == null) return null;
    return Method((m) {
      m
        ..annotations.add(CodeExpression(Code('override')))
        ..returns = refer(me.type.returnType.getDisplayString(withNullability: true))
        ..name = me.displayName
        ..modifier = me.returnType.isDartAsyncFuture ? MethodModifier.async : MethodModifier.asyncStar
        ..types.addAll(me.typeParameters.map((e) => refer(e.name)));

      m..body = Block.of([Code('{}')]);
    });
  }

  TypeChecker _typeChecker(Type type) => TypeChecker.fromRuntime(type);
}

extension DartReturnTypeExt on DartType {
  bool get isDartAsyncStream {
    final element = this.element == null ? null : this.element as ClassElement;
    if (element == null) return false;
    return element.name == 'Stream' && element.library.isDartAsync;
  }
}
