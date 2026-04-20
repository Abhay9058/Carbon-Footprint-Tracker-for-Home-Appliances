import 'package:flutter_test/flutter_test.dart';
import 'package:eco_warrior/main.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const EcoWarriorApp());
    await tester.pumpAndSettle();
  });
}
