import 'package:duplacert/pages/Gerenciar_Torneio/torneios.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class ModificarTorneio extends StatefulWidget {
  final String idTorneio;

  ModificarTorneio({required this.idTorneio});

  @override
  State<ModificarTorneio> createState() => _ModificiarTorneio();
}

class _ModificiarTorneio extends State<ModificarTorneio> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  String nomeTorneio = '';
  String codigoTorneio = '';
  int numeroMaximoParticipantes = 0;
  int participantesAtuais = 0;
  List<String> participantes = [];

  @override
  void initState() {
    super.initState();
    _carregarDadosTorneio();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          nomeTorneio.isEmpty ? 'Carregando...' : nomeTorneio,
          style: const TextStyle(
              fontSize: 25, fontFamily: 'inter', color: Colors.black),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nome do torneio
            Text(
              nomeTorneio,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            // Código do torneio e ícone de lápis
            Row(
              children: [
                Text(
                  'Código do torneio: $codigoTorneio',
                  style: TextStyle(fontSize: 18),
                ),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: _copiarCodigo,
                ),
              ],
            ),
            SizedBox(height: 10),

            // Progresso dos participantes
            Text(
              'Participantes: $participantesAtuais/$numeroMaximoParticipantes',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),

            // Barra de progresso visual
            LinearProgressIndicator(
              value: numeroMaximoParticipantes != 0
                  ? participantesAtuais / numeroMaximoParticipantes
                  : 0.0, // Se o número máximo de participantes for 0, o valor da barra é 0
              backgroundColor: Colors.grey[300],
              color: Colors.green,
            ),
            SizedBox(height: 20),

            // Lista de participantes
            Text(
              'Participantes inscritos:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: participantes.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(
                          participantes[index][0]), // Letra inicial do nome
                    ),
                    title: Text(participantes[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _carregarDadosTorneio() async {
    DocumentSnapshot torneioSnapshot = await FirebaseFirestore.instance
        .collection('torneios')
        .doc(widget.idTorneio)
        .get();
// Verifique se o campo 'duplas' existe antes de acessá-lo

    if (torneioSnapshot.exists) {
      setState(() {
        nomeTorneio = torneioSnapshot['nome'];
        codigoTorneio = torneioSnapshot['codigoTorneio'];
        numeroMaximoParticipantes = torneioSnapshot['participantes'];

        // Verifique se 'data()' não é null antes de acessar 'containsKey'
        var dadosTorneio = torneioSnapshot.data() as Map<String, dynamic>?;

        if (dadosTorneio != null && dadosTorneio.containsKey('duplas')) {
          // Se 'duplas' existe, obtenha o número de participantes
          participantesAtuais = (dadosTorneio['duplas'] as List).length;
          participantes = List<String>.from(dadosTorneio['duplas']);
        } else {
          // Se 'duplas' não existe, inicialize os valores adequadamente
          participantesAtuais = 0;
          participantes = [];
        }
      });
    }
  }

  // Função para copiar o código do torneio
  void _copiarCodigo() {
    Clipboard.setData(ClipboardData(text: codigoTorneio));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Código do torneio copiado!')),
    );
  }
}
