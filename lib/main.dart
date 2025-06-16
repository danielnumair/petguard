import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'database/database_helper.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/pets_screen.dart';
import 'screens/cadastro_pet_screen.dart';
import 'screens/consultas_screen.dart';
import 'screens/vacinas_screen.dart';
import 'screens/vermifugos_screen.dart';
import 'screens/cadastro_consulta_screen.dart';
import 'screens/cadastro_vacina_screen.dart';
import 'screens/cadastro_vermifugo_screen.dart';
import 'screens/configuracoes_screen.dart';
import 'screens/recuperar_senha_screen.dart';
import 'services/notification_service.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database;
  tz.initializeTimeZones();
  await NotificationService.init();
  runApp(const PetGuardApp());
}

class PetGuardApp extends StatelessWidget {
  const PetGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetGuard',
      debugShowCheckedModeBanner: false,
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('pt', 'BR'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        fontFamily: 'Montserrat',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),

        // Pets
        '/pets': (context) => const PetsScreen(),
        '/cadastro_pet': (context) {
          final usuarioId = ModalRoute.of(context)!.settings.arguments as int;
          return CadastroPetScreen(usuarioId: usuarioId);
        },

        // Consultas
        '/consultas': (context) {
          final usuarioId = ModalRoute.of(context)!.settings.arguments as int;
          return ConsultasScreen(usuarioId: usuarioId);
        },
        '/cadastro_consulta': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return CadastroConsultaScreen(
            usuarioId: args['usuarioId'] as int,
            consulta: args['consulta'],
          );
        },

        // Vacinas
        '/vacinas': (context) {
          final usuarioId = ModalRoute.of(context)!.settings.arguments as int;
          return VacinasScreen(usuarioId: usuarioId);
        },
        '/cadastro_vacina': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return CadastroVacinaScreen(
            usuarioId: args['usuarioId'],
            vacina: args['vacina'],
          );
        },

        // Vermífugos
        '/vermifugos': (context) {
          final usuarioId = ModalRoute.of(context)!.settings.arguments as int;
          return VermifugosScreen(usuarioId: usuarioId);
        },
        '/cadastro_vermifugo': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return CadastroVermifugoScreen(
            usuarioId: args['usuarioId'],
            vermifugo: args['vermifugo'],
          );
        },

        // Configurações
        '/configuracoes': (context) => const ConfiguracoesScreen(),

        // Recuperar Senha
        '/recuperar': (context) => const RecuperarSenhaScreen(),
      },
    );
  }
}
