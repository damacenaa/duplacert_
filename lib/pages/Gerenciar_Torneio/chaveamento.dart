import 'package:duplacert/models/torneio_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class ChaveamentoPage extends StatefulWidget {
  final String torneioId;

  ChaveamentoPage({required this.torneioId});

  @override
  _ChaveamentoPageState createState() => _ChaveamentoPageState();
}

class _ChaveamentoPageState extends State<ChaveamentoPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int faseAtual = 1;
  int totalFases = 1;
  Map<String, List<String>> nomesDuplas = {};
  Map<String, String?> resultadosPartidas = {};
  bool carregandoNomes = true;
  Map<String, dynamic>? dadosTorneio; //Mapa para acesso aos dados do torneio

  @override
  void initState() {
    super.initState();
    _obterTotalFases();
    _carregarDadosDaFase();
  }

  @override //Build principál
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fase $faseAtual'),
        actions: [
          IconButton(icon: Icon(Icons.arrow_back), onPressed: faseAnterior),
          IconButton(icon: Icon(Icons.arrow_forward), onPressed: proximaFase),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('torneios')
            .doc(widget.torneioId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            final isFinalizado = data['status'] == 'finalizado';

            // Verifica o status e exibe o widget correspondente
            return isFinalizado ? telaResultadoFinal() : buildMainContent();
          } else {
            return Center(child: Text("Erro ao carregar dados do torneio"));
          }
        },
      ),
    );
  }

  Widget buildMainContent() {
    return Column(
      children: [
        Expanded(child: buildChaveamentoLayout()),
        FutureBuilder<bool>(
          future: verificarResultados(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data == true) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: enviarResultados,
                  child: Text('Enviar resultados'),
                ),
              );
            }
            return SizedBox();
          },
        ),
      ],
    );
  }

  Widget telaResultadoFinal() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Campeões',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            FutureBuilder<DocumentSnapshot>(
              future: buscarDadosTorneio(
                  widget.torneioId), // Função que busca os dados do torneio
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Erro ao carregar os dados do torneio.');
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return Text('Torneio não encontrado.');
                }

                // Dados foram carregados e estão disponíveis
                var dadosTorneio =
                    snapshot.data!.data() as Map<String, dynamic>;

                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Nome: ${dadosTorneio['nome']}',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Jogador2",
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    // Adicione outras informações que deseja exibir
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildChaveamentoLayout() {
    //Widget chaveamento
    return ListView.builder(
      itemCount: resultadosPartidas.keys.length,
      itemBuilder: (context, index) {
        String partidaId = resultadosPartidas.keys.elementAt(index);
        String dupla1Id;
        String dupla2Id;

// Verificar se o índice está dentro do intervalo
        if (index * 2 < nomesDuplas.keys.length) {
          dupla1Id = nomesDuplas.keys.elementAt(index * 2);
        } else {
          dupla1Id = 'teste'; // Valor fallback se o índice for inválido
        }

        if (index * 2 + 1 < nomesDuplas.keys.length) {
          dupla2Id = nomesDuplas.keys.elementAt(index * 2 + 1);
        } else {
          dupla2Id = 'teste'; // Valor fallback se o índice for inválido
        }

// Extrair os nomes das duplas com fallback
        String primeiroNomeDupla1 = nomesDuplas[dupla1Id]?[0] ?? 'Vencedores';
        String segundoNomeDupla1 =
            nomesDuplas[dupla1Id]?[1] ?? 'Fase ${faseAtual - 1}';

        String primeiroNomeDupla2 = nomesDuplas[dupla2Id]?[0] ?? 'Vencedores';
        String segundoNomeDupla2 =
            nomesDuplas[dupla2Id]?[1] ?? 'Fase ${faseAtual - 1}';
        return Card(
          color: Colors.amber,
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                    child: buildDuplaWidget(primeiroNomeDupla1,
                        segundoNomeDupla1, partidaId, dupla1Id)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text('X', style: TextStyle(fontSize: 18)),
                ),
                Expanded(
                    child: buildDuplaWidget(primeiroNomeDupla2,
                        segundoNomeDupla2, partidaId, dupla2Id)),
              ],
            ),
          ),
        );
      },
    );
  }

  String formatarNomeCompleto(String nomeCompleto) {
    List<String> partes = nomeCompleto.split(" ");
    if (partes.length > 1) {
      return "${partes[0]} ${partes[1][0]}.";
    } else {
      return nomeCompleto; // Caso tenha apenas um nome
    }
  }

  Widget buildDuplaWidget(
      String nome1, String nome2, String partidaId, String duplaId) {
    //Widget para monstar o layout dos confrontos entre duplas
    bool isChecked = resultadosPartidas[partidaId] == duplaId;
    return FutureBuilder<bool>(
      future: verificarResultados(),
      builder: (context, snapshot) {
        bool resultadoValido = snapshot.data ?? false;
        Color checkboxColor = resultadoValido ? Colors.amber : Colors.grey;
        return Container(
          padding: EdgeInsets.all(9),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 3,
                offset: Offset(0, 3),
              ),
            ],
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Usando Expanded para garantir que o texto ocupe o espaço disponível sem ultrapassar
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nome1,
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      overflow: TextOverflow
                          .ellipsis, // Limita o texto com reticências
                      maxLines:
                          1, // Garante que o texto fique em apenas uma linha
                    ),
                    Text(
                      nome2,
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 5),
              Checkbox(
                value: isChecked,
                onChanged: resultadoValido
                    ? (bool? newValue) {
                        if (newValue != null) {
                          setState(() {
                            resultadosPartidas[partidaId] =
                                newValue ? duplaId : null;
                          });
                        }
                      }
                    : null,
                activeColor: checkboxColor,
                checkColor: Colors.white,
              ),
            ],
          ),
        );
      },
    );
  }

  void proximaFase() {
    //Função para passar de fase
    if (faseAtual < totalFases) {
      setState(() {
        faseAtual++;
        nomesDuplas.clear();
      });
      _carregarDadosDaFase();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Já estamos na última fase!')),
      );
    }
  }

  void faseAnterior() {
    //Função para retroceder uma fase
    if (faseAtual > 1) {
      setState(() {
        faseAtual--;
        nomesDuplas.clear();
      });
      _carregarDadosDaFase();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Já estamos na primeira fase!')),
      );
    }
  }

  Future<DocumentSnapshot> buscarDadosTorneio(String idTorneio) async {
    return await FirebaseFirestore.instance
        .collection('torneios')
        .doc(idTorneio)
        .get();
  }

  Future<bool> verificarResultados() async {
    QuerySnapshot snapshot = await _firestore
        .collection('chaveamento')
        .doc(widget.torneioId)
        .collection('fase$faseAtual')
        .get();

    QuerySnapshot? snapshotFaseAnterior;

    if (faseAtual > 1) {
      snapshotFaseAnterior = await _firestore
          .collection('chaveamento')
          .doc(widget.torneioId)
          .collection('fase${faseAtual - 1}')
          .get();
    }

    bool faseAtualValida =
        snapshot.docs.every((doc) => doc['resultado'] == null);

    bool faseAnteriorValida =
        true; // Se não houver fase anterior, não impede a liberação do botão
    if (snapshotFaseAnterior != null) {
      faseAnteriorValida =
          snapshotFaseAnterior.docs.every((doc) => doc['resultado'] != null);
    }

    // Retorna true se a fase atual for válida (resultado == null) e a fase anterior (se existir) tiver resultado != null.
    return faseAtualValida && faseAnteriorValida;
  }

  Future<void> _carregarDadosDaFase() async {
    //Função para carregar dados da fase atual
    setState(() {
      carregandoNomes = true;
      nomesDuplas.clear();
      resultadosPartidas.clear();
    });

    List<String> idsDuplas = [];
    Map<String, String?> resultadosTemp = {};

    try {
      var snapshot = await _firestore
          .collection('chaveamento')
          .doc(widget.torneioId)
          .collection('fase$faseAtual')
          .get();

      for (var partida in snapshot.docs) {
        idsDuplas.add(partida['dupla1']);
        idsDuplas.add(partida['dupla2']);
        resultadosTemp[partida.id] = partida['resultado'] as String?;
      }

      await buscarNomes(idsDuplas);

      setState(() {
        resultadosPartidas = resultadosTemp;
        carregandoNomes = false;
      });
    } catch (e) {
      print("Erro ao carregar dados da fase: $e");
      setState(() {
        carregandoNomes = false;
      });
    }
  }

  Future<void> buscarNomes(List<String> idsDuplas) async {
    // Função que busca os nomes com base nos ids das duplas
    for (String idDupla in idsDuplas) {
      await Torneios().getDupla(idDupla, (nome1, nome2) {
        setState(() {
          // Armazena cada dupla como uma lista de duas strings (nomes dos participantes)
          nomesDuplas[idDupla] = [nome1, nome2];
        });
      });
    }
  }

  Future<void> _obterTotalFases() async {
    //Função para obter o total de fases do torneio
    //Obter total de fases
    final chaveamentoRef =
        _firestore.collection('chaveamento').doc(widget.torneioId);
    final chaveamentoSnapshot = await chaveamentoRef.get();
    if (chaveamentoSnapshot.exists) {
      setState(() {
        totalFases = chaveamentoSnapshot.data()!['totalFases'];
      });
    }
  }

  Future<void> enviarResultados() async {
    //Enviar resultados ao banco
    //Enviar Resultado para o Banco
    List<Future<void>> atualizacoes = [];

    // Envia os resultados de cada partida
    for (var partidaId in resultadosPartidas.keys) {
      String? idVencedora = resultadosPartidas[partidaId];
      if (idVencedora != null) {
        var atualizacao = FirebaseFirestore.instance
            .collection('chaveamento')
            .doc(widget.torneioId)
            .collection('fase$faseAtual')
            .doc(partidaId)
            .update({'resultado': idVencedora}).then((_) {
          print('Resultado enviado para a partida $partidaId: $idVencedora');
        }).catchError((error) {
          print('Erro ao enviar resultado: $error');
        });
        atualizacoes.add(atualizacao);
      }
    }

    await Future.wait(atualizacoes); // Aguarda a conclusão das atualizações

    // Obtém os vencedores da fase atual
    var partidasFaseAtual = await _firestore
        .collection('chaveamento')
        .doc(widget.torneioId)
        .collection('fase$faseAtual')
        .get();

    List<String> vencedores = [];
    for (var partida in partidasFaseAtual.docs) {
      String? vencedorId = partida['resultado'];
      if (vencedorId != null && vencedorId.isNotEmpty) {
        vencedores.add(vencedorId);
      }
    }

    vencedores.shuffle(); // Embaralha a ordem dos vencedores

    // Verifica se existe uma próxima fase
    var partidasProximaFase = await _firestore
        .collection('chaveamento')
        .doc(widget.torneioId)
        .collection('fase${faseAtual + 1}')
        .get();

    if (partidasProximaFase.docs.isNotEmpty &&
        partidasProximaFase.docs.length >= vencedores.length / 2) {
      // Atualiza a próxima fase se houver
      WriteBatch batch = _firestore.batch();
      int partidaIndex = 0;

      for (int i = 0; i < vencedores.length; i += 2) {
        if (i + 1 < vencedores.length) {
          var partidaDoc = partidasProximaFase.docs[partidaIndex];
          batch.update(partidaDoc.reference, {
            'dupla1': vencedores[i],
            'dupla2': vencedores[i + 1],
            'resultado': null, // Reinicia o campo 'resultado'
          });
          partidaIndex++;
        }
      }
      proximaFase();
      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Resultados enviados e sorteio realizado para a fase ${faseAtual}!')),
      );
    } else {
      // Obter a última partida da fase atual
// Obtém o único documento da fase atual (que é a fase final)
      var partidaFinalSnapshot = await _firestore
          .collection('chaveamento')
          .doc(widget.torneioId)
          .collection('fase$faseAtual')
          .get();

      if (partidaFinalSnapshot.docs.isNotEmpty) {
        // Como há apenas um documento, pegamos o primeiro e único
        var docPartidaFinal = partidaFinalSnapshot.docs.first;

        // Identifica o campeão e vice-campeão com base no campo resultado
        String campeaoId = docPartidaFinal['resultado'];
        String viceCampeaoId = (docPartidaFinal['dupla1'] != campeaoId)
            ? docPartidaFinal['dupla1']
            : docPartidaFinal['dupla2'];

        // Atualiza o documento do torneio com o status e os IDs do campeão e vice-campeão
        await _firestore.collection('torneios').doc(widget.torneioId).update({
          'status': 'finalizado',
          'campeaoId': campeaoId,
          'viceCampeaoId': viceCampeaoId,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Torneio finalizado! Campeão e vice armazenados.')),
        );
      }
    }
  }
}
