import 'package:duplacert/models/auth.dart';
import 'package:duplacert/pages/Auth/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class Cadastro extends StatefulWidget {
  const Cadastro({super.key});

  @override
  State<Cadastro> createState() => _Cadastro();
}

class _Cadastro extends State<Cadastro> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  static final RegExp emailRegExp = RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');

  // List of items in our dropdown menu
  final List<String> genderItems = [
    'Masculino',
    'Feminino',
    'Outro',
    'Não definido',
  ];

  String? selectedValue;
  final generoController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  final nomeController = TextEditingController();
  final confirmarsenha = TextEditingController();

  bool senhasCoincide = true;
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Positioned.fill(
          child: Image.asset(
            "assets/images/background.jpg",
            fit: BoxFit.cover,
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22.0),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white, // Fundo translúcido
                  ),
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    mainAxisSize: MainAxisSize
                        .min, // O conteúdo ajusta a altura ao conteúdo
                    children: [
                      const SizedBox(
                        height: 88,
                      ),
                      TextField(
                        controller: nomeController,
                        decoration: const InputDecoration(
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                              color: Color.fromARGB(255, 90, 87, 87),
                              width: 2,
                            )),
                            labelText: 'Nome completo',
                            labelStyle: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                            color: Color.fromARGB(255, 90, 87, 87),
                            width: 2,
                          )),
                          labelText: 'Email',
                          labelStyle: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Preencha o campo de email!'
                            : (emailRegExp.hasMatch(value)
                                ? null
                                : 'Digite um email válido!'),
                      ),
                      TextField(
                        controller: senhaController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                            color: Color.fromARGB(255, 90, 87, 87),
                            width: 2,
                          )),
                          labelText: 'Criar senha',
                          labelStyle: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        onChanged: (value) {
                          setState(() {
                            tornarVisivel(value);
                            senhasCoincide =
                                senhaController.text == confirmarsenha.text;
                          });
                        },
                      ),
                      const SizedBox(height: 10),

                      TextField(
                        controller: confirmarsenha,
                        obscureText: true,
                        decoration: const InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                            color: Color.fromARGB(255, 90, 87, 87),
                            width: 2,
                          )),
                          labelText: 'Confirmar senha',
                          labelStyle: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        onChanged: (value) {
                          setState(() {
                            tornarVisivel(value);
                            senhasCoincide =
                                senhaController.text == confirmarsenha.text;
                          });
                        },
                      ),
                      const SizedBox(height: 5),

                      // Senhas iguais ou não
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Visibility(
                          visible: _isVisible,
                          child: Text(
                            senhasCoincide
                                ? 'As senhas coincidem'
                                : 'As senhas não coincidem',
                            style: TextStyle(
                                color:
                                    senhasCoincide ? Colors.green : Colors.red,
                                fontSize: 16),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      DropdownButtonFormField2<String>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                            color: Color.fromARGB(255, 90, 87, 87),
                            width: 2,
                          )),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 15),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          // Add more decoration..
                        ),
                        hint: const Text(
                          'Selecione seu gênero',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        items: genderItems
                            .map((item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(
                                    item,
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 53, 52, 52),
                                      fontSize: 15,
                                    ),
                                  ),
                                ))
                            .toList(),
                        validator: (value) {
                          if (value == null) {
                            return 'Selecione seu gênero';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          generoController.text = value.toString();
                        },
                        onSaved: (value) {
                          selectedValue = value.toString();
                        },
                        buttonStyleData: const ButtonStyleData(
                          padding: EdgeInsets.only(right: 8),
                        ),
                        iconStyleData: const IconStyleData(
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: Color.fromARGB(255, 90, 87, 87),
                          ),
                          iconSize: 24,
                        ),
                        dropdownStyleData: DropdownStyleData(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        menuItemStyleData: const MenuItemStyleData(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextButton(
                        child: const Text(
                          "Já tem uma conta?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18,
                              color: Color.fromARGB(255, 49, 48, 48),
                              fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => login(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 15),
                      Container(
                        height: 55,
                        width: 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: const LinearGradient(colors: [
                            Color.fromARGB(249, 255, 239, 9),
                            Color.fromARGB(227, 236, 161, 20),
                          ]),
                        ),
                        child: SizedBox.expand(
                          child: TextButton(
                              child: const Text(
                                "Cadastrar",
                                style: TextStyle(
                                  color: Color.fromARGB(253, 8, 8, 8),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                              onPressed: () async {
                                try {
                                  await Authent()
                                      .createUserwithEmailAndPassword(
                                          nomeController.text,
                                          emailController.text,
                                          senhaController.text,
                                          generoController.text,
                                          context)
                                      .then((value) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => login(),
                                      ),
                                    );
                                  });
                                } catch (e) {
                                  print('Error: $e');
                                }
                                //criarConta(txtNome.text ,txtEmail.text, txtSenha.text, txtTelefone.text, txtDataNascimento.text, txtCpf.text, txtCodigoNutricionista.text ?? "", context);
                              }),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 47, // Controla quanto do logo fica para fora
          left: 0,
          right: 0,
          child: Center(
            child: Image.asset(
              'assets/images/logo_back.png', // Caminho da sua imagem de logo
              width: 140, // Ajuste o tamanho conforme necessário
            ),
          ),
        ),
      ]),
    );
  }

  void tornarVisivel(String input) {
    setState(() {
      // O widget se torna visível se algo foi digitado
      _isVisible = input.isNotEmpty;
    });
  }
}
