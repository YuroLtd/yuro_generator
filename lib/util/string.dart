extension StringExt on String? {
  bool isNullOrEmpty() => this == null || this!.isEmpty;

  bool isNullOrBlank() => this == null || this!.trim().isEmpty;
}
