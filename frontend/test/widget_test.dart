import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopmate/main.dart';

void main() {
  testWidgets('App loads', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: ShopMateApp()));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
