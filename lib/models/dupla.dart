import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Duplas {
  final FirebaseAuth auth = FirebaseAuth.instance;
  String idUser = FirebaseAuth.instance.currentUser!.uid;

  Future<void> criarDupla(String codTorneio, String codigoDupla) async {
    try {
      // Verifica o parceiro com o código fornecido
      QuerySnapshot uaidParceiro = await FirebaseFirestore.instance
          .collection('user')
          .where('codigo', isEqualTo: codigoDupla)
          .get();

      if (uaidParceiro.docs.isNotEmpty && codTorneio.isNotEmpty) {
        DocumentSnapshot parceiroDoc = uaidParceiro.docs.first;
        String idParceiro = parceiroDoc.id;

        // Verifica se o idUser ou o parceiro já estão cadastrados no torneio
        QuerySnapshot duplaExistente = await FirebaseFirestore.instance
            .collection('duplas')
            .where('idTorneio', isEqualTo: codTorneio)
            .where('idParticipante1', isEqualTo: idUser)
            .get();

        QuerySnapshot parceiroJaInscrito = await FirebaseFirestore.instance
            .collection('duplas')
            .where('idTorneio', isEqualTo: codTorneio)
            .where('idParticipante2', isEqualTo: idParceiro)
            .get();

        if (duplaExistente.docs.isNotEmpty ||
            parceiroJaInscrito.docs.isNotEmpty) {
          print('Um dos participantes já está inscrito neste torneio.');
        } else {
          // Cria a dupla caso ambos os participantes não estejam inscritos
          DocumentReference docRef =
              await FirebaseFirestore.instance.collection('duplas').add({
            'idParticipante1': idUser,
            'idParticipante2': idParceiro,
            'idTorneio': codTorneio,
          });

          String idDoDocumento = docRef.id;

          DocumentReference torneioRef =
              FirebaseFirestore.instance.collection('torneios').doc(codTorneio);

          await torneioRef.update({
            'duplas': FieldValue.arrayUnion([idDoDocumento]),
          });

          print('Dupla criada com sucesso. ID do documento: $idDoDocumento');
        }
      } else {
        print('Nenhum parceiro encontrado com o código fornecido.');
      }
    } catch (e) {
      print('Erro ao criar dupla: $e');
    }
  }
}
