// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:logbook_app_080/main.dart';

void main() {
  testWidgets('Onboarding smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Lanjut'), findsOneWidget);
    expect(find.text('Mulai Sekarang'), findsNothing);

    await tester.tap(find.text('Lanjut'));
    await tester.tap(find.text('Lanjut'));
    await tester.pump();

    expect(find.text('Lanjut'), findsNothing);
    expect(find.text('Mulai Sekarang'), findsOneWidget);
  });
}
