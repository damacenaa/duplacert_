import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duplacert/models/database.dart';
import 'package:duplacert/pages/Config/config.dart';
import 'package:flutter/material.dart';

class visualizarTorneios extends StatefulWidget {
  @override
  State<visualizarTorneios> createState() => _VisualizarTorneios();
}

class _VisualizarTorneios extends State<visualizarTorneios> {
  String? imageUrl;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    LoadUrlImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
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
          child: AppBar(
            toolbarHeight: 60,
            elevation: 6,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(249, 255, 239, 9),
                    Color.fromARGB(227, 236, 161, 20),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            title: Stack(
              alignment: Alignment.center,
              children: [
                const Align(
                  alignment: Alignment.center, // Centraliza o texto
                  child: Text(
                    'Meus Torneios',
                    style: TextStyle(
                      fontSize: 25,
                      fontFamily: 'inter',
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight, // Alinha a imagem à direita
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Config(),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(75),
                        child: imageUrl != null
                            ? Image.network(
                                imageUrl!,
                                fit: BoxFit.cover,
                                width: 40,
                                height: 40,
                              )
                            : const Icon(
                                Icons.account_circle,
                                size: 40,
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Center(
        child: Text('Tela de visualizar meus torneios'),
      ),
    );
  }

  Future<void> LoadUrlImage() async {
    String? _imageUrl = await DatabaseMethods().checkIfImageExists();
    setState(() {
      imageUrl = _imageUrl;
    });
  }
}
