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
