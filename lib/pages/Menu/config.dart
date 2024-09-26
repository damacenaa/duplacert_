import 'dart:convert';
import 'package:duplacert/models/database.dart';
import 'package:duplacert/pages/Auth/esqueceu_senha.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:http/http.dart' as http;
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

  TextEditingController generoController = TextEditingController();
  TextEditingController nameController = TextEditingController();

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
          style: TextStyle(fontSize: 25, fontFamily: 'inter'),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(249, 255, 239, 9),
                Color.fromARGB(227, 236, 161, 20),
              ], // Escolha as cores desejadas para o gradiente
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.only(
                top: 20,
              ),
              child: const Text(
                'Minha Conta',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Color.fromARGB(255, 70, 70, 70),
                    fontFamily: 'Inter',
                    fontSize: 30),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
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
                            width: 150,
                            height: 150,
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(75),
                          child: Image.network(
                            imageUrl!,
                            fit: BoxFit.cover,
                            width: 150,
                            height: 150,
                          ),
                        )
                  : const Icon(Icons.account_circle,
                      color: Color.fromARGB(255, 64, 64, 64), size: 150),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    enabled: _isEditing,
                    decoration: const InputDecoration(
                      labelText: 'Nome',
                      labelStyle: TextStyle(
                        color: Colors.black38,
                        fontSize: 19,
                      ),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                        color: Color.fromARGB(249, 255, 239, 9),
                        width: 2,
                      )),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  AbsorbPointer(
                    absorbing: !_isEditing,
                    child: DropdownButtonFormField2<String>(
                      isExpanded: true,
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        // Add more decoration..
                      ),
                      hint: Text(
                        generoController.text,
                        style: TextStyle(
                          fontSize: 17,
                          color: _isEditing
                              ? Colors.black
                              : Colors
                                  .grey, // Defina a cor com base em _isEditing
                        ),
                      ),
                      items: listGeneros
                          .map((item) => DropdownMenuItem<String>(
                                value: item,
                                child: Text(
                                  item,
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: _isEditing
                                        ? Colors.black
                                        : Colors
                                            .grey, // Defina a cor com base em _isEditing
                                  ),
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        generoController.text = value.toString();
                      },
                      onSaved: (value) {
                        selectedValue = value.toString();
                      },
                      iconStyleData: const IconStyleData(
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: Color.fromARGB(249, 255, 239, 9),
                        ),
                        iconSize: 24,
                      ),
                      dropdownStyleData: DropdownStyleData(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      menuItemStyleData: const MenuItemStyleData(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Container(
              width: 350,
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 250, 248, 248), // Cor de fundo
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color:
                        const Color.fromARGB(255, 78, 78, 78).withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(
                            8), // Espaçamento em todos os lados
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => esqueceu_senha(),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.lock,
                                color: const Color.fromARGB(202, 255, 86, 34),
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Alterar senha',
                                style: TextStyle(
                                  color: Color.fromARGB(200, 58, 58, 58),
                                  fontFamily: 'inter',
                                  fontSize: 17,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(
                            8), // Espaçamento em todos os lados
                        child: TextButton(
                          onPressed: () {
                            if (_isEditing) {
                              _updateUserData();
                            } else {
                              setState(() {
                                _isEditing = true;
                              });
                            }
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isEditing ? Icons.save : Icons.edit,
                                size: 20,
                                color: const Color.fromARGB(202, 255, 86, 34),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                _isEditing ? 'Salvar' : 'Editar',
                                style: const TextStyle(
                                  color: Color.fromARGB(200, 58, 58, 58),
                                  fontFamily: 'inter',
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 15,
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
                  'Sair',
                  style: TextStyle(
                    color: Color.fromARGB(255, 234, 234, 234),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
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

  Future<void> _updateUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('Usuário não autenticado.');
      return;
    }

    try {
      final docRef = _collectionReference.doc(user.uid);

      // Crie um novo mapa para os dados atualizados
      final updatedData = <String, dynamic>{};

      // Atualize apenas os campos que foram editados
      if (nameController.text.isNotEmpty) {
        updatedData['nome'] = nameController.text;
      }

      if (generoController.text.isNotEmpty) {
        updatedData['genero'] = generoController.text;
      }

      // Atualize os dados no Firestore
      await docRef.set(updatedData, SetOptions(merge: true));
      setState(() {
        _isEditing = false;
      });

      print('Dados do usuário atualizados com sucesso.');
    } catch (error) {
      print('Erro ao atualizar os dados do usuário: $error');
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
          nameController.text = data['nome'];
          generoController.text = data['genero'];
        });
      }
    } catch (error) {
      print('Erro ao carregar dados do usuário: $error');
    }
  }
}
