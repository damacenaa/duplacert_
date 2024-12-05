import 'dart:ffi';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Torneio {
  final String nome;
  final String categoria;
  final String cidade;
  final Timestamp dataTorneio;
  final String estado;
  final int numParticipantes;
  final String idTorneio;

  Torneio(
      {required this.nome,
      required this.categoria,
      required this.cidade,
      required this.dataTorneio,
      required this.estado,
      required this.numParticipantes,
      required this.idTorneio});
}

class Torneiocard extends StatelessWidget {
  final String nome;
  final String categoria;
  final String cidade;
  final String estado;
  final Timestamp dataTorneio;
  final int numParticipantes;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final String idTorneio;

  Torneiocard({
    required this.nome,
    required this.categoria,
    required this.onDelete,
    required this.onEdit,
    required this.cidade,
    required this.estado,
    required this.dataTorneio,
    required this.numParticipantes,
    required this.idTorneio,
  });

  @override
  Widget build(BuildContext context) {
    DateTime data = dataTorneio.toDate();
    String dataFormatado = DateFormat('dd/MM/yyyy').format(data);
    return Stack(
      children: [
        InkWell(
          onTap: onEdit,
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
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.map,
                            size: 20,
                            color: Color.fromARGB(216, 0, 0, 0),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            cidade,
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            ' - $estado',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Text(categoria),
                          Text(' - $numParticipantes duplas'),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            '$dataFormatado',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 160),
                          IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Color.fromARGB(
                                  202, 204, 31, 31), // Cor do ícone de exclusão
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('Confirmação de Exclusão'),
                                    content: Text(
                                        'Tem certeza de que deseja excluir este item?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(); // Fecha o AlertDialog
                                        },
                                        child: Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          onDelete();
                                          Navigator.of(context)
                                              .pop(); // Fecha o AlertDialog
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  content: Text(
                                                      'Torneio excluido com sucesso!')));
                                        },
                                        child: Text('Confirmar'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
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
