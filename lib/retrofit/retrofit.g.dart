part of 'retrofit.dart';

TypeChecker _typeChecker(Type type) => TypeChecker.fromRuntime(type);

extension DartTypeExt on DartType {
  bool get isNullable => this.nullabilitySuffix == NullabilitySuffix.question;

  bool get isDartAsyncStream {
    final element = this.element == null ? null : this.element as ClassElement;
    if (element == null) return false;
    return element.name == 'Stream' && element.library.isDartAsync;
  }

  bool get isBasicType =>
      checkType(String) ||
      checkType(int) ||
      checkType(double) ||
      checkType(num) ||
      checkType(Double) ||
      checkType(Float);

  bool get isCollectionType => checkType(List) || checkType(Map) || checkType(Set);

  bool checkType(Type type) => _typeChecker(type).isExactlyType(this);

  /// 用于List、Object获取单泛型
  DartType? genericOf() {
    if (this is InterfaceType && (this as InterfaceType).typeArguments.isNotEmpty) {
      return (this as InterfaceType).typeArguments.first;
    }
    return null;
  }

  /// 用于Map获取多泛型
  List<DartType>? genericListOf() {
    if (this is ParameterizedType) {
      return (this as ParameterizedType).typeArguments;
    }
    return null;
  }
}

extension MethodElementExt on MethodElement {
  /// 是否包含[Type]的注解
  bool containAnnotation(Type type) => _typeChecker(type).firstAnnotationOf(this, throwOnUnresolved: false) != null;

  /// 是否包含[Type]列表中任意一个注解
  bool containAnnotations(List<Type> types) {
    for (final type in types) {
      final annotation = _typeChecker(type).firstAnnotationOf(this, throwOnUnresolved: false);
      if (annotation != null) return true;
    }
    return false;
  }

  /// 获取[Type]类型的注解
  ConstantReader? getAnnotation(Type type) {
    final annotation = _typeChecker(type).firstAnnotationOf(this, throwOnUnresolved: false);
    return annotation != null ? ConstantReader(annotation) : null;
  }

  /// 获取[Type]列表中第一个匹配的注解
  ConstantReader? getFirstAnnotation(List<Type> types) {
    for (final type in types) {
      final annotation = _typeChecker(type).firstAnnotationOf(this, throwOnUnresolved: false);
      if (annotation != null) return ConstantReader(annotation);
    }
    return null;
  }

  /// 根据[Type]获取参数注解
  Map<ParameterElement, ConstantReader> getParameterAnnotations(Type type) {
    final map = <ParameterElement, ConstantReader>{};
    parameters.forEach((element) {
      final annotation = _typeChecker(type).firstAnnotationOf(element);
      if (annotation != null) map[element] = ConstantReader(annotation);
    });
    return map;
  }

  /// 获取[Type]的第一次参数注解
  Tuple2<ParameterElement, ConstantReader>? getFirstParameterAnnotation(Type type) {
    for (int i = 0; i < parameters.length; i++) {
      final element = parameters[i];
      final annotation = _typeChecker(type).firstAnnotationOf(element);
      if (annotation != null) return Tuple2(element, ConstantReader(annotation));
    }
    return null;
  }
}

extension ReferenceExt on Reference {
  /// [isAsyncStream] true则在表达式前面添加`yield`, 否则添加`return`
  ///
  /// [nullable] false则在表达式后面添加`!`
  Expression returnedIf({bool nullable = true, bool asyncStream = false}) {
    var expression = refer('${asyncStream ? 'yield' : 'return'} $symbol');
    if (!nullable) {
      expression = refer('${expression.symbol}!');
    }
    return expression;
  }
}

extension ExpressionExt on Expression {
  /// [nullable] true 返回this?.<name>  false 返回this!.<name>
  Expression propertyIf(String name, {bool nullable = false}) =>
      nullable ? this.nullSafeProperty(name) : this.nullChecked.property(name);
}

extension ClassElementExt on ClassElement {
  bool hasConstructor(String name) => constructors.where((element) => element.name == name).isNotEmpty;

  bool hasMethod(String name) => lookUpMethod(name, library) != null;
}

class Tuple2<T, E> {
  final T item1;
  final E item2;

  const Tuple2(this.item1, this.item2);
}
