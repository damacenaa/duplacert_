import 'package:duplacert/models/torneio_model.dart';
import 'package:duplacert/pages/Gerenciar_Torneio/chaveamento.dart';
import 'package:duplacert/pages/Gerenciar_Torneio/torneiosTela.dart';
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
  String status = '';
  String codigoTorneio = '';
  int numeroMaximoParticipantes = 0;
  int participantesAtuais = 0;
  List<String> participantes = [];
  Map<String, String> nomesDuplas = {};
  bool sorteioValidacao = false;
  final Torneios torneios = Torneios();

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
          'Informações do Torneio',
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
        padding: const EdgeInsets.all(18),
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
            const Text(
              'Participantes inscritos:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: ListView.builder(
                itemCount: participantes.length,
                itemBuilder: (context, index) {
                  String idDupla = participantes[index];
                  String nomeDaDupla = nomesDuplas[idDupla] ?? 'Carregando...';

                  return Column(
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: Icon(Icons.group_rounded),
                          title: Text(
                            nomeDaDupla,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w400),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.remove_circle,
                              color: status == 'Inscrições'
                                  ? const Color.fromARGB(
                                      255, 216, 53, 41) // Cor ativa
                                  : Colors.grey, // Cor desativada
                            ),
                            onPressed: status == 'Inscrições'
                                ? () {
                                    confirmacaoExclusao(context, idDupla);
                                  }
                                : null, // Desativa o botão
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: sorteioValidacao
                  ? () async {
                      print(participantesAtuais);
                      print('num$numeroMaximoParticipantes');
                      print(sorteioValidacao);
                      print(status);
                      if (status == 'Inscrições') {
                        await torneios
                            .realizarSorteioChaveamento(widget.idTorneio);
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChaveamentoPage(
                            torneioId: widget.idTorneio,
                          ),
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: sorteioValidacao
                    ? Colors.amber
                    : Colors.grey, // Cor do botão
                minimumSize: Size(double.infinity, 50), // Tamanho do botão
              ),
              child: Text(
                !sorteioValidacao
                    ? 'Participantes insuficientes'
                    : (status == 'Inscrições'
                        ? 'Realizar Sorteio'
                        : 'Visualizar Torneio'),
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void confirmacaoExclusao(BuildContext context, String idDupla) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: const Text('Tem certeza de que deseja excluir esta dupla?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o dialog sem ação
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Color.fromARGB(198, 158, 158, 158)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o dialog
                // Executa a remoção da dupla
                removerDupla(idDupla);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Dupla excluída com sucesso!')),
                );
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> removerDupla(String idDupla) async {
    final firestore = FirebaseFirestore.instance;

    try {
      final torneioRef = firestore.collection('torneios').doc(widget.idTorneio);

      await torneioRef.update({
        'duplas': FieldValue.arrayRemove([idDupla]),
      });

      // Exclui o documento correspondente na coleção 'duplas'
      final duplaRef = firestore.collection('duplas').doc(idDupla);
      await duplaRef.delete();

      print(
          'Dupla $idDupla removida com sucesso do torneio ${widget.idTorneio}');
    } catch (e) {
      print('Erro ao remover dupla: $e');
      throw Exception('Falha ao remover dupla.');
    }
    await _carregarDadosTorneio();
  }

  void habilitarSorteio() {
    setState(() {
      if (participantesAtuais == numeroMaximoParticipantes) {
        sorteioValidacao = true;
      } else {
        sorteioValidacao = false;
      }
    });
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
        status = torneioSnapshot['status'];

        // Verifique se 'data()' não é null antes de acessar 'containsKey'
        var dadosTorneio = torneioSnapshot.data() as Map<String, dynamic>?;

        if (dadosTorneio != null && dadosTorneio.containsKey('duplas')) {
          // Se 'duplas' existe, obtenha o número de participantes
          participantesAtuais = (dadosTorneio['duplas'] as List).length;
          participantes = List<String>.from(dadosTorneio['duplas']);
          buscarNomes(participantes);
          habilitarSorteio();
        } else {
          // Se 'duplas' não existe, inicialize os valores adequadamente
          participantesAtuais = 0;
          participantes = [];
        }
      });
    }
  }

  Future<void> buscarNomes(List<String> idsDuplas) async {
    for (String idDupla in idsDuplas) {
      Torneios().getDupla(idDupla, (nome1, nome2) {
        setState(() {
          nomesDuplas[idDupla] = '$nome1\n$nome2';
        });
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
