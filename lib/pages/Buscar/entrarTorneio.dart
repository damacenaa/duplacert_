import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duplacert/models/dupla.dart';
import 'package:duplacert/pages/Buscar/buscarTorneio.dart';
import 'package:flutter/material.dart';

class Entrartorneio extends StatefulWidget {
  final String idTorneio;

  Entrartorneio({required this.idTorneio});
  @override
  _Entrartorneio createState() => _Entrartorneio();
}

class _Entrartorneio extends State<Entrartorneio> {
  final TextEditingController codigoDuplaController = TextEditingController();
  String nomeDupla = ''; // Para armazenar o nome da dupla encontrado
  bool duplaEncontrada = false; // Controle para saber se o nome foi encontrado

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Inserir Código da Dupla',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          'Para ingressar no torneio, coloque o código do parceiro disponivel nas configurações do perfil.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 20),
        TextField(
          controller: codigoDuplaController,
          decoration: InputDecoration(
            labelText: 'Código da Dupla',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 20),
        Text(
          'Dupla: ${nomeDupla.isNotEmpty ? nomeDupla : ''}',
          textAlign: TextAlign.start,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            if (!duplaEncontrada) {
              // Busca dupla ao clicar no botão
              buscarDuplaPorCodigo(codigoDuplaController.text);
            } else
              Duplas().criarDupla(
                  widget.idTorneio, codigoDuplaController.text, context);
          },
          child: Text(
            duplaEncontrada ? 'Entrar no torneio' : 'Buscar',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 30),
        // Exibe o nome da dupla se encontrada
      ],
    );
  }

  Future<void> buscarDuplaPorCodigo(String codigo) async {
    try {
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('user')
          .where('codigo', isEqualTo: codigo)
          .limit(1)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        setState(() {
          var user = userSnapshot.docs.first;
          nomeDupla = user['nome'];
          duplaEncontrada = true;
        });
      } else {
        setState(() {
          nomeDupla = 'Código não encontrado';
          duplaEncontrada = false;
        });
      }
    } catch (e) {
      print('Erro ao buscar dupla: $e');
      setState(() {
        nomeDupla = 'Erro na busca';
        duplaEncontrada = false;
      });
    }
  }
}

void abrirConviteDupla(BuildContext context, String codTorneio) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
    ),
    builder: (BuildContext bottomSheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Entrartorneio(
          idTorneio: codTorneio,
        ),
      );
    },
  );
}
