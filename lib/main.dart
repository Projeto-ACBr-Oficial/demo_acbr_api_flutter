import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/cnpj_controller.dart';
import 'controllers/cep_controller.dart';
import 'services/auth_service.dart';
import 'services/cnpj_service.dart';
import 'services/cep_service.dart';
import 'core/network/http_client.dart';
import 'core/constants/api_constants.dart';
import 'views/home/home_screen.dart';

void main() {
  _assertCredentials();
  runApp(const AcbrApiApp());
}

/// Valida em tempo de execução que as credenciais foram fornecidas via
/// --dart-define. Lança [AssertionError] apenas em modo debug/profile.
void _assertCredentials() {
  assert(
    ApiConstants.clientId.isNotEmpty,
    '\n\n'
    '╔══════════════════════════════════════════════════════╗\n'
    '║           CREDENCIAL AUSENTE: CLIENT_ID              ║\n'
    '╠══════════════════════════════════════════════════════╣\n'
    '║  Execute com:                                        ║\n'
    '║  flutter run \\                                       ║\n'
    '║    --dart-define=CLIENT_ID=<seu_client_id> \\         ║\n'
    '║    --dart-define=CLIENT_SECRET=<seu_secret>          ║\n'
    '║                                                      ║\n'
    '║  Ou via arquivo:                                     ║\n'
    '║  flutter run --dart-define-from-file=.env.sandbox    ║\n'
    '╚══════════════════════════════════════════════════════╝\n',
  );
  assert(
    ApiConstants.clientSecret.isNotEmpty,
    '\n\n'
    '╔══════════════════════════════════════════════════════╗\n'
    '║         CREDENCIAL AUSENTE: CLIENT_SECRET            ║\n'
    '╠══════════════════════════════════════════════════════╣\n'
    '║  Execute com:                                        ║\n'
    '║  flutter run \\                                       ║\n'
    '║    --dart-define=CLIENT_ID=<seu_client_id> \\         ║\n'
    '║    --dart-define=CLIENT_SECRET=<seu_secret>          ║\n'
    '╚══════════════════════════════════════════════════════╝\n',
  );
  if (kDebugMode) {
    debugPrint('[Config] API_BASE_URL : ${ApiConstants.apiBaseUrl}');
    debugPrint('[Config] CLIENT_ID    : ***HIDDEN***');
    debugPrint('[Config] CLIENT_SECRET: ***HIDDEN***');
  }
}

class AcbrApiApp extends StatefulWidget {
  const AcbrApiApp({super.key});

  @override
  State<AcbrApiApp> createState() => _AcbrApiAppState();
}

class _AcbrApiAppState extends State<AcbrApiApp> {
  late final HttpClient _httpClient;
  late final AuthService _authService;
  late final CnpjController _cnpjController;
  late final CepController _cepController;

  @override
  void initState() {
    super.initState();
    _httpClient = HttpClient();
    _authService = AuthService(httpClient: _httpClient);
    _cnpjController = CnpjController(
      service: CnpjService(
        httpClient: _httpClient,
        authService: _authService,
      ),
    );
    _cepController = CepController(
      service: CepService(
        httpClient: _httpClient,
        authService: _authService,
      ),
    );
  }

  @override
  void dispose() {
    _cnpjController.dispose();
    _cepController.dispose();
    _httpClient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CnpjController>.value(value: _cnpjController),
        ChangeNotifierProvider<CepController>.value(value: _cepController),
      ],
      child: MaterialApp(
        title: 'ACBr API',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        home: const HomeScreen(),
      ),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1565C0),
        brightness: Brightness.light,
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
