import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Torneio {
  final String nome;
  final String categoria;
  final String cidade;
  final Timestamp dtaCriacao;
  final String estado;
  final int numParticipantes;
  final String idTorneio;

  Torneio(
      {required this.nome,
      required this.categoria,
      required this.cidade,
      required this.dtaCriacao,
      required this.estado,
      required this.numParticipantes,
      required this.idTorneio});
}

class Torneiocard extends StatelessWidget {
  final String nome;
  final String categoria;
  final String cidade;
  final String estado;
  final int numParticipantes;
  final VoidCallback onDelete;
  final String idTorneio;

  Torneiocard({
    required this.nome,
    required this.categoria,
    required this.onDelete,
    required this.cidade,
    required this.estado,
    required this.numParticipantes,
    required this.idTorneio, // Atualizado para aceitar String? ou null
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      // Usamos um Stack para sobrepor o botão sobre o card
      children: [
        Container(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nome: $nome',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('Categoria: $categoria',
                        style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              Divider(
                color: Colors.grey, // Adicione uma linha divisória
              ),
              SizedBox(height: 5), // Adicione um espaço após o Divider
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
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
                                  // Adicione aqui a lógica para exclusão do item
                                  onDelete();
                                  Navigator.of(context)
                                      .pop(); // Fecha o AlertDialog
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
    );
  }
}
