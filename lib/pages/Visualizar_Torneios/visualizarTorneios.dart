import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duplacert/models/database.dart';
import 'package:duplacert/pages/Config/config.dart';
import 'package:duplacert/pages/Gerenciar_Torneio/torneioCard.dart';
import 'package:duplacert/pages/Visualizar_Torneios/meuTorneio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class visualizarTorneios extends StatefulWidget {
  @override
  State<visualizarTorneios> createState() => _VisualizarTorneios();
}

class _VisualizarTorneios extends State<visualizarTorneios> {
  String? imageUrl;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Torneio> torneios = [];
  String idUser = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    LoadUrlImage();
    carregarTorneio();
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
            centerTitle: true,
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
                    sairTorneio();
                  },
                  onEdit: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MeuTorneio(
                          torneioId: torneios[index].idTorneio,
                        ),
                      ),
                    );
                  },
                  isAdmin: false,
                );
              },
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  void sairTorneio() {
    print("Saido");
  }

  Future<void> carregarTorneio() async {
    List<Torneio> torneioTemp = [];
    try {
      final duplasSnapshot = await FirebaseFirestore.instance
          .collection('duplas')
          .where(FieldPath.documentId, isNotEqualTo: null)
          .get();

      List<String> torneioIds = duplasSnapshot.docs
          .where((doc) => doc.data().containsValue(idUser))
          .map((doc) => doc['idTorneio'] as String)
          .toList();

      if (torneioIds.isEmpty) {
        return;
      }

      final torneiosSnapshot = await FirebaseFirestore.instance
          .collection('torneios')
          .where(FieldPath.documentId, whereIn: torneioIds)
          .get();

      for (QueryDocumentSnapshot document in torneiosSnapshot.docs) {
        final idTorneio = document.id;
        final nome = document['nome'];
        final categoria = document['categoria'];
        final cidade = document['cidade'];
        final estado = document['estado'];
        final participantes = document['participantes'];
        final dataTorneio = document['dataTorneio'];

        torneioTemp.add(Torneio(
          idTorneio: idTorneio,
          nome: nome,
          categoria: categoria,
          cidade: cidade,
          estado: estado,
          numParticipantes: participantes,
          dataTorneio: dataTorneio,
        ));
      }
      setState(() {
        torneios = torneioTemp;
      });
    } catch (e) {
      print('Erro ao buscar os torneios: $e');
      // Lançar uma exceção ou simplesmente logar o erro
    }
  }

  Future<void> LoadUrlImage() async {
    String? _imageUrl = await DatabaseMethods().checkIfImageExists();
    setState(() {
      imageUrl = _imageUrl;
    });
  }
}
