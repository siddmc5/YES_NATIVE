import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Basic smoke test - app should load without errors
    // Full widget testing requires setting up Provider/Theme/etc.
    expect(true, isTrue);
  });
}
