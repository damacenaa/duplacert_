import 'package:duplacert/pages/Config/config.dart';
import 'package:duplacert/pages/Menu/menuPrincipal.dart';
import 'package:duplacert/pages/Auth/cadastro.dart';
import 'package:duplacert/pages/Auth/esqueceu_senha.dart';
import 'package:duplacert/pages/Auth/loadinScreen.dart';
import 'package:duplacert/pages/Auth/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Duplacert',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: scaffoldMessengerKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(
              255, 110, 110, 110), // Define a cor de destaque
          primary: Color.fromARGB(227, 236, 161, 20), // Cor principal
          secondary: const Color.fromARGB(255, 110, 110, 110),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          contentTextStyle: TextStyle(
            color: Color.fromARGB(219, 0, 0, 0),
            fontSize: 16.0,
          ),
          backgroundColor: Color.fromARGB(255, 229, 229, 230),
        ),
      ),
      routes: {
        'login': (context) => login(),
        'esqueceu senha': (context) => esqueceu_senha(),
        'cadastro': (context) => const Cadastro(),
        'menu principal': (context) => const menuPrincipal(),
        'config': (context) => const Config(),
      },
      home: LoadingScreen(),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: [
        const Locale('pt', 'BR'), // Português do Brasil
      ],
    );
  }
}
