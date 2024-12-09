import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TorneioInsert {
  final String nome;
  final String categoria;
  final String cidade;
  final Timestamp dataTorneio;
  final String estado;
  final int numParticipantes;
  final String idTorneio;

  TorneioInsert(
      {required this.nome,
      required this.categoria,
      required this.cidade,
      required this.dataTorneio,
      required this.estado,
      required this.numParticipantes,
      required this.idTorneio});
}

class TorneiocardInsert extends StatelessWidget {
  final String nome;
  final String categoria;
  final String cidade;
  final String estado;
  final Timestamp dataTorneio;
  final int numParticipantes;
  final String idTorneio;
  final VoidCallback join;

  TorneiocardInsert(
      {required this.nome,
      required this.categoria,
      required this.cidade,
      required this.estado,
      required this.dataTorneio,
      required this.numParticipantes,
      required this.idTorneio,
      required this.join});

  @override
  Widget build(BuildContext context) {
    DateTime data = dataTorneio.toDate();
    String dataFormatado = DateFormat('dd/MM/yyyy').format(data);
    return Stack(
      children: [
        InkWell(
          onTap: join,
          child: Container(
            width: 350,
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white, // Cor de fundo
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nome,
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.map,
                            size: 23,
                            color: Color.fromARGB(216, 0, 0, 0),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            cidade,
                            style: const TextStyle(
                              fontSize: 19,
                            ),
                          ),
                          Text(
                            ' - $estado',
                            style: const TextStyle(fontSize: 19),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Text(
                            categoria,
                            style: TextStyle(fontSize: 17),
                          ),
                          Text(
                            ' - $numParticipantes duplas',
                            style: TextStyle(fontSize: 17),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            '$dataFormatado',
                            style: const TextStyle(
                                fontSize: 23, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 160),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
