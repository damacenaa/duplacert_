import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duplacert/models/database.dart';
import 'package:duplacert/pages/Buscar/entrarTorneio.dart';
import 'package:duplacert/pages/Config/config.dart';
import 'package:flutter/material.dart';

class buscarTorneio extends StatefulWidget {
  @override
  State<buscarTorneio> createState() => _BuscarTorneioState();
}

class _BuscarTorneioState extends State<buscarTorneio> {
  String? imageUrl;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController codigoTorneio = TextEditingController();

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
                color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 5),
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
                  alignment: Alignment.center,
                  child: Text(
                    'Buscar Torneios',
                    style: TextStyle(
                      fontSize: 25,
                      fontFamily: 'inter',
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
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
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 50),
            Center(
              child: Text(
                "Insira o código do torneio para entrar",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Container(
                width: 200,
                child: Column(
                  children: [
                    TextField(
                      controller: codigoTorneio,
                      decoration: const InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 90, 87, 87),
                            width: 2,
                          ),
                        ),
                        labelText: 'Código do Torneio',
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        child: const Text(
                          "Buscar",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color: Color.fromARGB(226, 236, 55, 45),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          buscarTorneioPorCodigo(
                              codigoTorneio.text, _firestore, context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
