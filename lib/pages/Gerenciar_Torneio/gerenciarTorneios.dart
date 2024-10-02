import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:duplacert/models/database.dart';
import 'package:duplacert/models/torneio.dart';
import 'package:duplacert/pages/Config/config.dart';
import 'package:duplacert/pages/Gerenciar_Torneio/criacaoTorneio.dart';
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

  @override
  void initState() {
    super.initState();
    LoadUrlImage();
    carregarTorneios();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        automaticallyImplyLeading: false,
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Config(),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(75),
                child: imageUrl != null
                    ? Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        width: 55,
                        height: 55,
                      )
                    : const Icon(
                        Icons.account_circle,
                        size: 55,
                      ),
              ),
            ),
          ),
          const SizedBox(width: 25),
        ],
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
              child: const Text(
                'Gerenciamento de Torneios',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color.fromARGB(255, 37, 37, 37),
                  fontFamily: 'Inter',
                  fontSize: 30,
                ),
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
                    onDelete: () async {
                      deleteTorneio(torneios[index].idTorneio);
                    });
              },
            ),
            const SizedBox(
              height: 10,
            ),
            IconButton(
              iconSize: 60,
              icon: Icon(Icons.add_circle),
              color: Color.fromARGB(138, 6, 6, 6),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CriarTorneio(),
                  ),
                );
              },
            ),
          ],
        ),
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
