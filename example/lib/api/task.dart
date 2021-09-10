import 'package:json_annotation/json_annotation.dart';

part 'task.g.dart';

@JsonSerializable()
class Task extends Object {
  @JsonKey(name: 'id')
  String id;

  @JsonKey(name: 'category')
  String category;

  Task(
    this.id,
    this.category,
  );

  factory Task.fromJson(Map<String, dynamic> srcJson) => _$TaskFromJson(srcJson);

  Map<String, dynamic> toJson() => _$TaskToJson(this);
}
