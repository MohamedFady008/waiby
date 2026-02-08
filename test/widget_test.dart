import 'package:flutter_test/flutter_test.dart';

import 'package:waiby/main.dart';

void main() {
  testWidgets('App loads with top navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Waiby'), findsWidgets);
    expect(find.text('Social'), findsOneWidget);
    expect(find.text('Playground'), findsOneWidget);
    expect(find.text('FAQ'), findsOneWidget);
  });
}
