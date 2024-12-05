import 'package:duplacert/models/database.dart';
import 'package:duplacert/pages/Auth/esqueceu_senha.dart';
import 'package:duplacert/pages/Config/telaEdicao.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class Config extends StatefulWidget {
  const Config({super.key});

  @override
  State<Config> createState() => _Config();
}

class _Config extends State<Config> {
  final List<String> listGeneros = [
    'Masculino',
    'Feminino',
    'Outro',
    'Não definido',
  ];
  bool _isEditing = false;
  String? selectedValue;

  String generoString = '';
  String nomeString = '';
  String categoriaString = '';
  String codigoUser = '';

  File? imageFile;
  final picker = ImagePicker();
  String? imageUrl;
  @override
  void initState() {
    super.initState();
    _loadUserData();
    LoadUrlImage();
  }

  CollectionReference _collectionReference =
      FirebaseFirestore.instance.collection("user");

  var especController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Configurações',
          style: TextStyle(
            fontSize: 25,
            fontFamily: 'inter',
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(249, 255, 239, 9),
                Color.fromARGB(227, 236, 161, 20),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 0, 0, 0)
                    .withOpacity(0.1), // Cor da sombra
                spreadRadius: 2, // O quão grande a sombra será
                blurRadius: 10, // O quão desfocada será a sombra
                offset: const Offset(
                    0, 5), // Posição da sombra (0,5) para projetar para baixo
              ),
            ],
          ),
        ),
      ),
      backgroundColor:
          const Color.fromARGB(239, 255, 255, 255), // Cor de fundo branca
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 40),
              decoration: BoxDecoration(
                color: Colors.white, // Cor do card
                borderRadius: BorderRadius.circular(20), // Bordas arredondadas
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2), // Sombra sutil
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 5), // Sombra embaixo
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment
                        .center, // Centraliza os itens no eixo horizontal
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () async {
                          await _pickImage(ImageSource.gallery);
                        },
                        child: (imageFile != null || imageUrl != null)
                            ? imageFile != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        75), // Define o raio para tornar a imagem circular
                                    child: Image.file(
                                      imageFile!,
                                      fit: BoxFit.cover,
                                      width: 120,
                                      height: 120,
                                    ),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(75),
                                    child: Image.network(
                                      imageUrl!,
                                      fit: BoxFit.cover,
                                      width: 120,
                                      height: 120,
                                    ),
                                  )
                            : const Icon(Icons.account_circle,
                                color: Color.fromARGB(
                                    255, 37, 37, 37), // Ícone cinza
                                size: 130),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width *
                            0.5, // Limita a largura do container
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nomeString,

                              softWrap:
                                  true, // Permite quebra automática de linha
                              overflow: TextOverflow
                                  .clip, // Clipa o texto caso ele exceda o tamanho
                              style: const TextStyle(
                                color: Color.fromARGB(255, 37, 37, 37),
                                fontFamily: 'Inter',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                const Text(
                                  'Gênero: ', // Texto fixo
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 37, 37, 37),
                                    fontFamily: 'Inter',
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  generoString,
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 37, 37, 37),
                                    fontFamily: 'Inter',
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                const Text(
                                  'Categoria: ', // Texto fixo
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 37, 37, 37),
                                    fontFamily: 'Inter',
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  categoriaString,
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 37, 37, 37),
                                    fontFamily: 'Inter',
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ), // Espaço entre o nome e a categoria
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 25,
                      ),
                      Text(
                        'Código do usuário: $codigoUser',
                        style: TextStyle(fontSize: 18),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: _copiarCodigo,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Divider(
                    color: Colors.grey, // Cor da linha divisória
                    thickness: 1,
                    indent: 40,
                    endIndent: 40,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceEvenly, // Espaço entre os itens
                    children: [
                      // Torneios Participados
                      Column(
                        children: [
                          Text(
                            'Torneios Participados',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color.fromARGB(193, 0, 0, 0),
                              fontFamily: 'Inter',
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            '10', // Número de torneios participados
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFFECA120),
                              fontFamily: 'Inter',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      // Torneios Ganhos
                      Column(
                        children: [
                          Text(
                            'Torneios Ganhos',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color.fromARGB(202, 0, 0, 0),
                              fontFamily: 'Inter',
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            '5', // Número de torneios ganhos
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFFECA120),
                              fontFamily: 'Inter',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 6,
                      offset: const Offset(0, 2), // Sombra sutil
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => esqueceu_senha(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.lock,
                        color: Color(0xFFECA120),
                      ),
                      label: const Text(
                        'Alterar senha',
                        style: TextStyle(
                          color: Colors.black54,
                          fontFamily: 'Inter',
                          fontSize: 18,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        _AbrirEdicaodeDados(context);
                      },
                      icon: const Icon(
                        Icons.edit,
                        color: Color(0xFFECA120),
                      ),
                      label: const Text(
                        'Editar',
                        style: TextStyle(
                          color: Colors.black54,
                          fontFamily: 'Inter',
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 50),
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
                  'Sair',
                  style: TextStyle(
                    color: Color.fromARGB(255, 32, 32, 32),
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                onPressed: () async {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushReplacementNamed(context, 'login');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
      await DatabaseMethods().uploadImage(imageFile!);
    }
  }

  Future<void> LoadUrlImage() async {
    String? _imageUrl = await DatabaseMethods().checkIfImageExists();
    setState(() {
      imageUrl = _imageUrl;
    });
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('Usuário não autenticado.');
      return;
    }

    try {
      final snapshot = await _collectionReference.doc(user.uid).get();
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;

        setState(() {
          nomeString = data['nome'];
          generoString = data['genero'];
          categoriaString = data['categoria'];
          codigoUser = data['codigo'];
        });
      }
    } catch (error) {
      print('Erro ao carregar dados do usuário: $error');
    }
  }

  Future<void> _AbrirEdicaodeDados(BuildContext context) async {
    bool? updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => telaEdicao(
          userId: FirebaseAuth.instance.currentUser?.uid ?? '',
          nomeAtual: nomeString,
          generoAtual: generoString,
        ),
      ),
    );

    if (updated == true) {
      _loadUserData();
    }
  }

  void _copiarCodigo() {
    Clipboard.setData(ClipboardData(text: codigoUser));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Código do torneio copiado!')),
    );
  }
}
