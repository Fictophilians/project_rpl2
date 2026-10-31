import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_rpl2/pages/StarterPage.dart';

void main() {
  testWidgets('StarterPage displays app title and navigation buttons', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: StarterPage(),
      ),
    );

    expect(find.text('GameHaven'), findsOneWidget);
    expect(find.text('Mulai Sekarang'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });
}
