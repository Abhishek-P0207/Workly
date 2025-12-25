import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:task_manager/app.dart';

void main() {
  testWidgets('Task Dashboard loads', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: SmartTaskManagerApp(),
      ),
    );

    // Verify that the app bar title is present
    expect(find.text('Task Dashboard'), findsOneWidget);
  });
}
