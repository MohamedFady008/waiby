import 'package:flutter_test/flutter_test.dart';

import 'package:waiby/main.dart';
import 'package:waiby/widgets/top_nav_bar.dart';

void main() {
  testWidgets('App loads with top navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Waiby'), findsWidgets);

    final topNav = find.byType(TopNavBar);
    expect(topNav, findsOneWidget);

    expect(
      find.descendant(of: topNav, matching: find.text('Social')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: topNav, matching: find.text('Playground')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: topNav, matching: find.text('FAQ')),
      findsOneWidget,
    );
  });
}
