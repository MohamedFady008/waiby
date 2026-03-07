import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:waiby/widgets/common/responsive_layout.dart';

void main() {
  test('waibyHorizontalPaddingForWidth uses breakpoint-based spacing', () {
    expect(waibyHorizontalPaddingForWidth(360), 16);
    expect(waibyHorizontalPaddingForWidth(700), 20);
    expect(waibyHorizontalPaddingForWidth(900), 20);
    expect(waibyHorizontalPaddingForWidth(1024), 24);
  });

  testWidgets('WaibyConstrainedContent renders child', (WidgetTester tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: WaibyConstrainedContent(
          child: Text('child-content'),
        ),
      ),
    );

    expect(find.text('child-content'), findsOneWidget);
    expect(find.byType(WaibyConstrainedContent), findsOneWidget);
  });
}
