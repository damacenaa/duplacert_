import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:duplacert/models/database.dart';
import 'package:duplacert/models/torneio_model.dart';
import 'package:duplacert/pages/Config/config.dart';
import 'package:duplacert/pages/Gerenciar_Torneio/criacaoTorneio.dart';
import 'package:duplacert/pages/Gerenciar_Torneio/visualizarTorneio.dart';
import 'package:duplacert/pages/Gerenciar_Torneio/torneioCard.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class GerenciarTorneios extends StatefulWidget {
  @override
  State<GerenciarTorneios> createState() => _GerenciarTorneios();
}

class _GerenciarTorneios extends State<GerenciarTorneios> {
  String? imageUrl;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String userId = FirebaseAuth.instance.currentUser!.uid;
  List<Torneio> torneios = [];
  bool sorteioValidacao = false;

  @override
  void initState() {
    super.initState();
    LoadUrlImage();
    carregarTorneios();
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
                    'Gerenciar Torneios',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 15,
          right: 15,
        ),
        child: Column(
          children: [
            Container(
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.only(
                top: 30,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: torneios.length,
              itemBuilder: (context, index) {
                return Torneiocard(
                  nome: torneios[index].nome,
                  categoria: torneios[index].categoria,
                  cidade: torneios[index].cidade,
                  estado: torneios[index].estado,
                  numParticipantes: torneios[index].numParticipantes,
                  idTorneio: torneios[index].idTorneio,
                  dataTorneio: torneios[index].dataTorneio,
                  onDelete: () async {
                    deleteTorneio(torneios[index].idTorneio);
                  },
                  onEdit: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ModificarTorneio(
                            idTorneio: torneios[index].idTorneio),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool? torneioCriado = await showModalBottomSheet(
            context: context,
            builder: (context) {
              return CriarTorneio();
            },
          );

          // Se o torneio foi criado, recarregue a lista
          if (torneioCriado == true) {
            await carregarTorneios(); // Função para recarregar os torneios
          }
        },
        backgroundColor: Color.fromARGB(235, 236, 160, 20),
        foregroundColor: const Color.fromARGB(255, 5, 5, 5),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> deleteTorneio(String idTorneio) async {
    try {
      // Primeiro, você pode buscar o documento na coleção 'perfil' com base no campo 'idServico'
      QuerySnapshot perfilQuery = await FirebaseFirestore.instance
          .collection('torneios')
          .where('idTorneio', isEqualTo: idTorneio)
          .get();

      if (perfilQuery.docs.isNotEmpty) {
        // Se houver documentos correspondentes na coleção 'perfil', exclua-os
        for (QueryDocumentSnapshot doc in perfilQuery.docs) {
          await FirebaseFirestore.instance
              .collection('perfis')
              .doc(doc.id)
              .delete();
        }
      }

      // Em seguida, você pode excluir o documento na coleção 'servicos'
      await FirebaseFirestore.instance
          .collection('torneios')
          .doc(idTorneio)
          .delete();
      await carregarTorneios();
    } catch (e) {
      print('Erro ao excluir o serviço: $e');
    }
  }

  Future<void> carregarTorneios() async {
    List<Torneio> torneioList = await Torneios().getTorneio(userId);
    setState(() {
      torneios = torneioList;
    });
    print("Busca torneio: $torneioList");
  }

  Future<void> LoadUrlImage() async {
    String? _imageUrl = await DatabaseMethods().checkIfImageExists();
    setState(() {
      imageUrl = _imageUrl;
    });
  }
}
