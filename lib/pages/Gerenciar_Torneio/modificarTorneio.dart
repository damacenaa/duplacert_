import 'package:duplacert/pages/Gerenciar_Torneio/torneios.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ModificarTorneio extends StatefulWidget {
  ModificarTorneio(String idTorneio);

  @override
  State<ModificarTorneio> createState() => _ModificiarTorneio();
}

class _ModificiarTorneio extends State<ModificarTorneio> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cadastro de Torneio',
          style:
              TextStyle(fontSize: 25, fontFamily: 'inter', color: Colors.black),
        ),
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Form(
          key: _formKey,
          child: Column(
            children: [],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return GerenciarTorneios();
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
