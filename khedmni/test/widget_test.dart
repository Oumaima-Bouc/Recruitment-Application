import 'package:flutter_test/flutter_test.dart';
import 'package:khedmni/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const KhedmniApp());

    // Verify that the welcome text appears.
    expect(find.text('Welcome to Khedmni \nYour gateway to internships and job opportunities!'), findsOneWidget);
  });
}
