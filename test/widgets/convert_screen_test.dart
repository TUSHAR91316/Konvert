import 'package:converter_app/screens/convert_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ConvertScreen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: ConvertScreen(initialFormat: 'pdf'),
    ));

    await tester.pumpAndSettle();

    expect(find.text('Convert File'), findsOneWidget);
    expect(find.text('Tap to Select Files'), findsOneWidget);
    expect(find.text('DOCUMENT SETUP'), findsOneWidget);
    expect(find.text('A4'), findsOneWidget);
    expect(find.text('Letter'), findsOneWidget);
    expect(find.text('OUTPUT QUALITY'), findsOneWidget);
    expect(find.text('SAVE LOCATION'), findsOneWidget);
    expect(find.text('Output Folder'), findsOneWidget);
  });
}
