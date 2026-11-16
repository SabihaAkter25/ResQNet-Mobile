
import 'package:flutter_test/flutter_test.dart';
import 'package:resqnet_app/main.dart';
import 'package:resqnet_app/features/splash/presentation/screens/welcome_screen.dart';

void main() {
  testWidgets('ResQNetApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ResQNetApp());

    expect(find.byType(WelcomeScreen), findsOneWidget);
  });
}
