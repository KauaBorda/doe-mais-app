import 'package:flutter_test/flutter_test.dart';

import 'package:doe_mais_app/app.dart';

void main() {
  testWidgets('App inicializa e mostra a splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const DoeMaisApp());
    await tester.pump();

    expect(find.text('Doe+'), findsOneWidget);
  });
}
