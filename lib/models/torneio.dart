import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duplacert/pages/Gerenciar_Torneio/torneioCard.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Torneios {
  final FirebaseAuth auth = FirebaseAuth.instance;
  String idUser = FirebaseAuth.instance.currentUser!.uid;

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
            dataTorneio: dataTorneio));
      }
    } catch (e) {
      print('Erro ao buscar os serviços: $e');
      // Você pode lançar uma exceção personalizada aqui se preferir.
    }

    return torneioList;
  }
}
