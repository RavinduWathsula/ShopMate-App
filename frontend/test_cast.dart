import 'package:flutter/foundation.dart';

void main() {
  dynamic extra = {'id': 'x', 'price': 100.0, 'originalPrice': null};
  try {
    var m = extra as Map<String, dynamic>?;
    debugPrint("Success: ${m.runtimeType}");
  } catch (e) {
    debugPrint("Error: $e");
  }
}
