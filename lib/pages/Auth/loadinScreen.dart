import 'package:flutter/material.dart';
import 'dart:async';
import 'login.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addListener(() {
        setState(() {});
      });
    _startLoading();
    controller.forward();
  }

  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // Método que simula o carregamento em 3 segundos
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Cor de fundo
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 100,
              ),
              Image.asset(
                'assets/images/logo.png', // Caminho para sua imagem
                height: 300.0, // Tamanho da imagem
              ),
              SizedBox(
                width: 250,
                child: LinearProgressIndicator(
                  value: controller.value,
                  borderRadius: const BorderRadius.all(Radius.circular(50)),
                  color: const Color.fromARGB(255, 90, 87, 87),
                  // Valor da animação de progresso
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startLoading() {
    Timer(Duration(seconds: 3), () {
      _navigateToLoginScreen(); // Navega para a tela de login após 5 segundos
    });
  }

  void _navigateToLoginScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => login(), // Usa o nome da classe login
      ),
    );
  }
}
