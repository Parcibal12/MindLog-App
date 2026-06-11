import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindlog_app/main.dart';

void main() {
  testWidgets('App startup test', (WidgetTester tester) async {
    // Envolvemos la app en ProviderScope tal como lo hicimos en main.dart
    await tester.pumpWidget(const ProviderScope(child: MindLogApp()));
    
    // Verificamos que la pantalla de Login cargue correctamente
    expect(find.text('Bienvenido de nuevo'), findsOneWidget);
  });
}