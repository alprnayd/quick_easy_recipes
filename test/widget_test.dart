import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Quick and Easy Recipes basic widget test',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('Quick & Easy Recipes'),
            ),
          ),
        ),
      );

      expect(
        find.text('Quick & Easy Recipes'),
        findsOneWidget,
      );
    },
  );
}