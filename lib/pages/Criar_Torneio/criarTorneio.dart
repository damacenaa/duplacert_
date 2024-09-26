import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duplacert/models/database.dart';
import 'package:duplacert/pages/Menu/config.dart';
import 'package:flutter/material.dart';

class criarTorneio extends StatefulWidget {
  @override
  State<criarTorneio> createState() => _CriarTorneio();
}

class _CriarTorneio extends State<criarTorneio> {
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
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(75),
                child: imageUrl != null
                    ? Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        width: 43,
                        height: 43,
                      )
                    : const Icon(
                        Icons.account_circle,
                        size: 43,
                      ),
              ),
            ),
          ),
          const SizedBox(width: 25),
        ],
      ),
      body: Center(
        child: Text('Events Screen'),
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
