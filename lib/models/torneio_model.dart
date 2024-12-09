import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duplacert/pages/Buscar/torneioCardInsert.dart';
import 'package:duplacert/pages/Gerenciar_Torneio/torneioCard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Torneios {
  final FirebaseAuth auth = FirebaseAuth.instance;
  String idUser = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Torneio>> getTorneio(String userId) async {
    List<Torneio> torneioList = [];

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('torneios')
          .where('administrador', isEqualTo: userId)
          .get();

      for (QueryDocumentSnapshot document in querySnapshot.docs) {
        final idTorneio = document.id;
        final nome = document['nome'];
        final categoria = document['categoria'];
        final cidade = document['cidade'];
        final estado = document['estado'];
        final participantes = document['participantes'];
        final dataTorneio = document['dataTorneio'];

        torneioList.add(Torneio(
          idTorneio: idTorneio,
          nome: nome,
          categoria: categoria,
          cidade: cidade,
          estado: estado,
          numParticipantes: participantes,
          dataTorneio: dataTorneio,
        ));
      }
    } catch (e) {
      print('Erro ao buscar os serviços: $e');
      // Você pode lançar uma exceção personalizada aqui se preferir.
    }

    return torneioList;
  }

  Future<List<TorneioInsert>> getTorneioById(String codigo) async {
    List<TorneioInsert> torneioList = [];

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('torneios')
          .where('codigoTorneio', isEqualTo: codigo)
          .limit(1)
          .get();

      for (QueryDocumentSnapshot document in querySnapshot.docs) {
        final idTorneio = document.id;
        final nome = document['nome'];
        final categoria = document['categoria'];
        final cidade = document['cidade'];
        final estado = document['estado'];
        final participantes = document['participantes'];
        final dataTorneio = document['dataTorneio'];

        torneioList.add(TorneioInsert(
            idTorneio: idTorneio,
            nome: nome,
            categoria: categoria,
            cidade: cidade,
            estado: estado,
            numParticipantes: participantes,
            dataTorneio: dataTorneio));
      }
    } catch (e) {
      print('Erro ao buscar os serviços: $e');
      // Você pode lançar uma exceção personalizada aqui se preferir.
    }

    return torneioList;
  }

  Future<void> getDupla(
      String idDupla, Function(String, String) nomesObtidos) async {
    try {
      DocumentSnapshot duplaSnapshot = await FirebaseFirestore.instance
          .collection('duplas')
          .doc(idDupla)
          .get();

      if (duplaSnapshot.exists) {
        String idParticipante1 = duplaSnapshot['idParticipante1'];
        String idParticipante2 = duplaSnapshot['idParticipante2'];

        DocumentSnapshot participante1Snapshot = await FirebaseFirestore
            .instance
            .collection('user')
            .doc(idParticipante1)
            .get();

        DocumentSnapshot participante2Snapshot = await FirebaseFirestore
            .instance
            .collection('user')
            .doc(idParticipante2)
            .get();

        if (participante1Snapshot.exists && participante2Snapshot.exists) {
          String nomeParticipante1 = participante1Snapshot['nome'];
          String nomeParticipante2 = participante2Snapshot['nome'];

          // Passa os nomes para o callback
          nomesObtidos(nomeParticipante1, nomeParticipante2);
        } else {
          print('Participante(s) não encontrado(s).');
        }
      } else {
        print('Dupla não encontrada.');
      }
    } catch (e) {
      print('Erro ao buscar nomes dos participantes: $e');
    }
  }

  Future<void> realizarSorteioChaveamento(String torneioId) async {
    await FirebaseFirestore.instance
        .collection('torneios')
        .doc(torneioId)
        .update({
      'status': 'Em andamento',
    });

    final torneioRef =
        FirebaseFirestore.instance.collection('torneios').doc(torneioId);
    final torneioSnapshot = await torneioRef.get();

    // Obtenha o array de IDs de duplas do torneio
    List<dynamic> duplasIds = torneioSnapshot.data()!['duplas'];
    duplasIds.shuffle(); // Embaralha para randomizar o sorteio

    final chaveamentoRef =
        FirebaseFirestore.instance.collection('chaveamento').doc(torneioId);

    // Calcula o número total de rodadas com base no número de duplas
    int totalFases = (duplasIds.length).bitLength - 1;

    // Função para criar uma fase e suas partidas
    Future<void> criarFase(int fase, List<dynamic> duplas,
        [int? proximaFase]) async {
      final faseRef = chaveamentoRef.collection('fase$fase');

      for (int i = 0; i < duplas.length; i += 2) {
        var dupla1 = duplas[i];
        var dupla2 = (i + 1 < duplas.length) ? duplas[i + 1] : null;

        // Cria a partida com duplas e resultado nulo
        await faseRef.add({
          'dupla1': dupla1,
          'dupla2': dupla2,
          'resultado': null,
          'fase': fase,
        });
      }
    }

    // Criação das fases dinamicamente
    List<dynamic> duplasAtuais = duplasIds;
    for (int fase = 1; fase <= totalFases; fase++) {
      int? proximaFase = (fase < totalFases) ? fase + 1 : null;
      await criarFase(fase, duplasAtuais, proximaFase);

      // Reduz o número de duplas pela metade para a próxima fase
      duplasAtuais = List.generate(
        duplasAtuais.length ~/ 2,
        (index) => 'vencedor_fase${fase}_$index',
      );
    }

    // Definir as informações gerais do chaveamento
    await chaveamentoRef.set({
      'idTorneio': torneioId,
      'numduplas': duplasIds.length,
      'totalFases': totalFases, // Número de fases dinâmico
    });

    print("Chaveamento criado com sucesso!");
  }

  Future<bool> verificarResultados(String idtorneio, int faseAtual) async {
    var snapshot = await _firestore
        .collection('chaveamento')
        .doc(idtorneio)
        .collection('fase$faseAtual')
        .get();

    bool faseAtualValida = snapshot.docs.any((doc) => doc['resultado'] == null);

    if (faseAtual > 1) {
      var faseAnteriorSnapshot = await _firestore
          .collection('chaveamento')
          .doc(idtorneio)
          .collection('fase${faseAtual - 1}')
          .get();
      bool faseAnteriorCompleta =
          faseAnteriorSnapshot.docs.any((doc) => doc['resultado'] != null);

      return faseAnteriorCompleta && faseAtualValida;
    }

    return faseAtualValida;
  }

  Future<bool> verificarStatus(String idtorneio, int faseAtual) async {
    // Verifica se a fase atual tem status 'Finalizado'
    if (faseAtual == 1) {
      return false;
    }
    var snapshotAtual = await FirebaseFirestore.instance
        .collection('chaveamento')
        .doc(idtorneio)
        .collection('fase${faseAtual}')
        .get();
    bool faseAtualFinalizada =
        snapshotAtual.docs.any((doc) => doc['resultado'] != null);

    if (faseAtualFinalizada) return false;

    var snapshotFaseAnterior = await FirebaseFirestore.instance
        .collection('chaveamento')
        .doc(idtorneio)
        .collection('fase${faseAtual - 1}')
        .limit(1)
        .get();

    if (snapshotFaseAnterior.docs.isNotEmpty) {
      bool faseAnteriorFinalizada =
          snapshotFaseAnterior.docs.any((doc) => doc['status'] == 'Finalizado');

      return faseAnteriorFinalizada;
    }

    // Se não existe uma próxima fase, retorna true porque só a fase atual está 'Finalizado'
    return true;
  }

  Future<void> limparFase(
      String torneioId, int faseAtual, Map<String, String?> idPartidas) async {
    List<String> idsPartidaAnt =
        await buscarIdsFaseAnterior(torneioId, faseAtual);
    for (var partidaId in idPartidas.keys) {
      await FirebaseFirestore.instance
          .collection('chaveamento')
          .doc(torneioId)
          .collection('fase$faseAtual')
          .doc(partidaId)
          .update({
        'dupla1': 'Participante1',
        'dupla2': 'Participante2',
      });
    }
    for (var partidaId in idsPartidaAnt) {
      await FirebaseFirestore.instance
          .collection('chaveamento')
          .doc(torneioId)
          .collection('fase${faseAtual - 1}')
          .doc(partidaId)
          .update({
        'resultado': null,
        'status': 'Não finalizado',
      });
    }
  }

  Future<List<String>> buscarIdsFaseAnterior(
      String idTorneio, faseAtual) async {
    try {
      // Referência ao documento do torneio dentro da coleção 'chaveamento'
      final DocumentReference torneioRef =
          FirebaseFirestore.instance.collection('chaveamento').doc(idTorneio);

      // Snapshot da subcoleção 'faseatual'
      final QuerySnapshot subcolecaoSnapshot =
          await torneioRef.collection('fase${faseAtual - 1}').get();

      // Extração dos IDs dos documentos na subcoleção
      List<String> ids = subcolecaoSnapshot.docs.map((doc) => doc.id).toList();

      return ids;
    } catch (e) {
      print('Erro ao buscar IDs da fase atual: $e');
      return [];
    }
  }
}
