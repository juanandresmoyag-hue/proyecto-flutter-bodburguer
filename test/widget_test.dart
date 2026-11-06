import 'package:flutter_test/flutter_test.dart';

import 'package:bod_burguer/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BodBurguerApp());
    expect(find.text('INICIAR SESIÓN'), findsOneWidget);
  });
}
