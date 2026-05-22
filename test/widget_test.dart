import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:acbr_api_flutter/main.dart';
import 'package:acbr_api_flutter/controllers/cnpj_controller.dart';
import 'package:acbr_api_flutter/controllers/cep_controller.dart';
import 'package:acbr_api_flutter/views/home/home_screen.dart';

void main() {
  testWidgets('HomeScreen renderiza corretamente', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CnpjController()),
          ChangeNotifierProvider(create: (_) => CepController()),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    expect(find.text('ACBr API'), findsWidgets);
    expect(find.text('Consulta CNPJ'), findsOneWidget);
    expect(find.text('Consulta CEP'), findsOneWidget);
  });

  testWidgets('AcbrApiApp inicializa sem erros', (WidgetTester tester) async {
    await tester.pumpWidget(const AcbrApiApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
