T? asType<T>(dynamic data,) {
  if (data is T) {
    return data;
  }
  return null;
}

Map<String, dynamic>? asMap(dynamic data,) {
  return asType<Map<String, dynamic>>(data,);
}

T? asMapAndCast<T>(dynamic data, T Function(Map<String, dynamic> data,) builder,) {
  final map = asMap(data,);
  if (map != null) {
    return builder(map,);
  }
  return null;
}

List? asList(dynamic data,) {
  if (data is List) {
    return data;
  }
  return null;
}