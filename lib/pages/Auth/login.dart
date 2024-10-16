import 'package:duplacert/models/auth.dart';
import 'package:duplacert/pages/Auth/cadastro.dart';
import 'package:duplacert/pages/Auth/esqueceu_senha.dart';
import 'package:duplacert/pages/Auth/loadinScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class login extends StatelessWidget {
  login({super.key});

  @override
  Widget build(BuildContext context) {
    var emailController = TextEditingController();
    var senhaController = TextEditingController();

    return Scaffold(
        body: Container(
      width: double.maxFinite,
      height: double.maxFinite,
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            bottom: MediaQuery.of(context).size.height / 2,
            child: Image.asset(
              "assets/images/futvolei.jpg",
            ),
          ),
          Positioned(
            top: 60,
            left: 32,
            child: Text(
              'Olá, seja \nbem vindo!',
              style: TextStyle(
                fontSize: 33,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    offset: Offset(2.0, 2.0), // Deslocamento da sombra
                    blurRadius: 3.0, // Grau de desfoque
                    color: Colors.black.withOpacity(0.1), // Cor da sombra
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 200,
            child: Container(
              padding: EdgeInsets.all(32),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(
                    height: 30,
                  ),
                  TextFormField(
                    controller: emailController,
                    autofocus: true, //-----------------
                    keyboardType:
                        TextInputType.emailAddress, //-----------------
                    decoration: const InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                          color: Color.fromARGB(255, 90, 87, 87),
                          width: 2,
                        )),
                        label: Text(
                          'E-mail',
                          style: TextStyle(
                            fontSize: 20,
                            color: Color.fromARGB(255, 90, 87, 87),
                          ),
                        )),
                  ),
                  TextFormField(
                    controller: senhaController,
                    autofocus: true,
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    decoration: const InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                          color: Color.fromARGB(255, 110, 110, 110),
                          width: 2,
                        )),
                        label: Text(
                          'Senha',
                          style: TextStyle(
                            fontSize: 20,
                            color: Color.fromARGB(255, 103, 101, 101),
                          ),
                        )),
                  ),
                  const SizedBox(
                    height: 18,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                        child: const Text(
                          'Esqueceu a senha?',
                          style: TextStyle(
                              fontFamily: 'Inter-Thin',
                              fontSize: 16,
                              color: Color.fromARGB(255, 97, 95, 95)),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => esqueceu_senha(),
                            ),
                          );
                        }),
                  ),
                  const SizedBox(
                    height: 70,
                  ),
                  Container(
                    height: 55,
                    width: 300,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                      gradient: LinearGradient(colors: [
                        Color.fromARGB(249, 255, 239, 9),
                        Color.fromARGB(227, 236, 161, 20),
                      ]),
                    ),
                    child: TextButton(
                      child: const Text(
                        "Entrar",
                        style: TextStyle(
                            color: Color.fromARGB(253, 8, 8, 8),
                            fontSize: 23,
                            fontFamily: 'Inter'),
                      ),
                      onPressed: () => _loginUser(
                          emailController.text, senhaController.text, context),
                    ),
                  ),
                  const SizedBox(
                    height: 70,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Não tem uma conta?',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: Color.fromARGB(255, 65, 65, 64),
                          fontSize: 18,
                        ),
                      ),
                      TextButton(
                        child: const Text(
                          "Cadastre-se",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18,
                              color: Color.fromARGB(255, 47, 47, 48),
                              fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Cadastro(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }

  Future<void> _loginUser(email, senha, context) async {
    //Navigator.pushReplacementNamed(context, 'menuPrincipal');
    try {
      await Authent().loginSenhaEmail(email, senha).then((value) {});
      Navigator.pushReplacementNamed(context, 'menu principal');
    } on FirebaseException catch (e) {
      var msg = '';
      if (e.code == 'Usuário não existente!') {
        msg = 'ERRO: Usuario não encontrado';
      } else if (e.code == 'wrong-password') {
        msg = 'ERRO: Senha incorreta';
      } else if (e.code == 'invalid-email') {
        msg = 'ERRO: Email inválido';
      } else {
        msg = 'ERRO: ${e.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          duration: Duration(
            seconds: 2,
          ),
        ),
      );
    }
  }
}
