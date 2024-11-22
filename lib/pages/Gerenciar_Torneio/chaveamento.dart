import 'dart:async';
import 'package:duplacert/models/torneio_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  Map<String, String> nomesDuplas = {};
  Map<String, String?> resultadosPartidas = {};
  bool carregandoNomes = true;
<<<<<<< Updated upstream
  Color corCheckbox = Colors.blue;
=======
  bool isFinalizado = false;
  DocumentSnapshot? dadosTorneio; //Mapa para acesso aos dados do torneio
>>>>>>> Stashed changes

  @override
  void initState() {
    super.initState();
    carregarDadosIniciais();
  }

<<<<<<< Updated upstream
=======
  @override
  Widget build(BuildContext context) {
    //Main widget
    if (isFinalizado) {
      return telaResultadoFinal();
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('Fase $faseAtual'),
          actions: [
            FutureBuilder<bool>(
              future: Torneios().verificarStatus(widget.torneioId, faseAtual),
              builder: (context, snapshot) {
                // Considera como `true` se `snapshot.data` for `true` ou `null`
                bool isEnabled = snapshot.data == true;
                return IconButton(
                  icon: Icon(Icons.refresh_rounded),
                  onPressed: isEnabled
                      ? () async {
                          Torneios().limparFase(
                              widget.torneioId, faseAtual, resultadosPartidas);
                          faseAnterior();
                        }
                      : null,
                  color: Colors.amber,
                  iconSize: 30,
                );
                // Retorna um widget vazio enquanto aguarda o futuro
              },
            ),
            IconButton(icon: Icon(Icons.arrow_back), onPressed: faseAnterior),
            IconButton(icon: Icon(Icons.arrow_forward), onPressed: proximaFase),
          ],
        ),
        body: carregandoNomes
            ? Center(child: CircularProgressIndicator())
            : chaveamentoWidget(),
      );
    }
  }

  Widget chaveamentoWidget() {
    return Column(
      children: [
        Expanded(child: confrontoLayout()),
        FutureBuilder<bool>(
          future: Torneios().verificarResultados(widget.torneioId, faseAtual),
          builder: (context, snapshot) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: enviarResultados,
                child: Text('Enviar resultados'),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget confrontoLayout() {
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
          dupla1Id = 'vazio'; // Valor fallback se o índice for inválido
        }

        if (index * 2 + 1 < nomesDuplas.keys.length) {
          dupla2Id = nomesDuplas.keys.elementAt(index * 2 + 1);
        } else {
          dupla2Id = 'vazio'; // Valor fallback se o índice for inválido
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
                    child: duplaWidget(primeiroNomeDupla1, segundoNomeDupla1,
                        partidaId, dupla1Id)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text('X', style: TextStyle(fontSize: 18)),
                ),
                Expanded(
                    child: duplaWidget(primeiroNomeDupla2, segundoNomeDupla2,
                        partidaId, dupla2Id)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget duplaWidget(
      String nome1, String nome2, String partidaId, String duplaId) {
    //Widget para monstar o layout dos confrontos entre duplas
    bool isChecked = resultadosPartidas[partidaId] == duplaId;
    return FutureBuilder<bool>(
      future: Torneios().verificarResultados(widget.torneioId, faseAtual),
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

  Widget telaResultadoFinal() {
    // Exibe o resultado final dos campeões
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Resultado do Torneio',
          style: TextStyle(
            fontSize: 25,
            fontFamily: 'inter',
          ),
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Campeões',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              nomesDuplas[dadosTorneio!['campeaoId']] != null
                  ? "${nomesDuplas[dadosTorneio!['campeaoId']]![0]} e ${nomesDuplas[dadosTorneio!['campeaoId']]![1]}"
                  : 'Carregando...',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            Text(
              'Vice-campeões',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              nomesDuplas[dadosTorneio!['viceCampeaoId']] != null
                  ? "${nomesDuplas[dadosTorneio!['viceCampeaoId']]![0]} e ${nomesDuplas[dadosTorneio!['viceCampeaoId']]![1]}"
                  : 'Carregando...',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            Text(
              'Participantes',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: nomesDuplas.length,
                itemBuilder: (context, index) {
                  String idDupla = nomesDuplas.keys.elementAt(index);
                  List<String>? nomes = nomesDuplas[idDupla];

                  String nomeDaDupla = nomes != null
                      ? "${nomes[0]} e ${nomes[1]}"
                      : 'Carregando...';

                  return Column(
                    children: [
                      SizedBox(height: 20),
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
                          title: Text(
                            nomeDaDupla,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w400),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

>>>>>>> Stashed changes
  void proximaFase() {
    if (faseAtual < totalFases) {
      setState(() {
        faseAtual++;
        nomesDuplas.clear();
        _carregarDadosDaFase();
      });
<<<<<<< Updated upstream
      resultadosPartidas = {};
      _carregarDadosDaFase();
=======
>>>>>>> Stashed changes
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Já estamos na última fase!')),
      );
    }
  }

  void faseAnterior() {
    if (faseAtual > 1) {
      setState(() {
        faseAtual--;
        nomesDuplas.clear();
        _carregarDadosDaFase();
      });
<<<<<<< Updated upstream
      resultadosPartidas = {};
      _carregarDadosDaFase();
=======
>>>>>>> Stashed changes
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Já estamos na primeira fase!')),
      );
    }
  }

<<<<<<< Updated upstream
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fase $faseAtual'),
        actions: [
          IconButton(icon: Icon(Icons.arrow_back), onPressed: faseAnterior),
          IconButton(icon: Icon(Icons.arrow_forward), onPressed: proximaFase),
        ],
      ),
      body: carregandoNomes
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: buildChaveamentoLayout(),
                ),
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
            ),
    );
  }

  Widget buildChaveamentoLayout() {
    return ListView.builder(
      itemCount: resultadosPartidas.keys.length,
      itemBuilder: (context, index) {
        String partidaId = resultadosPartidas.keys.elementAt(index);
        String dupla1Id = nomesDuplas.keys.elementAt(index * 2);
        String dupla2Id = nomesDuplas.keys.elementAt(index * 2 + 1);

        String dupla1 =
            nomesDuplas[dupla1Id] ?? 'Vencedor fase $faseAtual-1...';
        String dupla2 =
            nomesDuplas[dupla2Id] ?? 'Vencedor fase $faseAtual-1...';

        return Card(
          color: Colors.amber,
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                    child: buildDuplaWidget(dupla1, partidaId, dupla1Id, true)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text('X', style: TextStyle(fontSize: 18)),
                ),
                Expanded(
                    child:
                        buildDuplaWidget(dupla2, partidaId, dupla2Id, false)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildDuplaWidget(
      String dupla, String partidaId, String duplaId, bool isDupla1) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 3),
          ),
        ],
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              dupla,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 8),
          Checkbox(
            activeColor: corCheckbox,
            value: resultadosPartidas[partidaId] == duplaId,
            onChanged: (bool? newValue) async {
              if (newValue != null) {
                // Chama a função assíncrona
                bool resultadoValido = await verificarResultados();

                if (resultadoValido) {
                  setState(() {
                    resultadosPartidas[partidaId] = newValue ? duplaId : null;
                  });
                } else {
                  setState(() {
                    // Muda o estado de uma variável de controle de cor, por exemplo:
                    corCheckbox = Colors.grey; // Define a cor como cinza
                  });
                  activeColor:
                  corCheckbox == Colors.grey
                      ? Colors.grey
                      : Colors.black; // Usa a variável de controle de cor
                  inactiveColor:
                  corCheckbox == Colors.grey
                      ? Colors.grey
                      : Colors.yellow; // Define a cor inativa
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _carregarDadosDaFase() async {
    setState(() {
      carregandoNomes = true;
      nomesDuplas.clear();
      resultadosPartidas.clear();
    });

=======
  Future<void> _carregarDadosDaFase() async {
    setState(() => carregandoNomes = true);
>>>>>>> Stashed changes
    List<String> idsDuplas = [];
    Map<String, String?> resultadosTemp = {};

    try {
      var snapshot = await _firestore
          .collection('chaveamento')
          .doc(widget.torneioId)
          .collection('fase$faseAtual')
          .get();

      for (var partida in snapshot.docs) {
        idsDuplas.addAll([partida['dupla1'], partida['dupla2']]);
        resultadosTemp[partida.id] = partida['resultado'] as String?;
      }

      await buscarNomes(idsDuplas);
      setState(() {
        resultadosPartidas = resultadosTemp;
        carregandoNomes = false;
      });
    } catch (e) {
      print("Erro ao carregar dados da fase: $e");
      setState(() => carregandoNomes = false);
    }
  }

  Future<void> buscarNomes(List<String> idsDuplas) async {
    for (String idDupla in idsDuplas) {
      await Torneios().getDupla(idDupla, (nome1, nome2) {
        setState(() {
<<<<<<< Updated upstream
          nomesDuplas[idDupla] = '$nome1\n$nome2';
=======
          nomesDuplas[idDupla] = [nome1, nome2];
>>>>>>> Stashed changes
        });
      });
    }
  }

<<<<<<< Updated upstream
  Future<void> _obterTotalFases() async {
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

  Stream<QuerySnapshot> getPartidasDaFase(int fase) {
    //Buscar partidas da fase
    return FirebaseFirestore.instance
        .collection('chaveamento')
        .doc(widget.torneioId)
        .collection('fase$fase')
        .snapshots();
  }

  Future<bool> verificarResultados() async {
    //Verifica o resultado para mostrar o botão
    // Obtém as partidas da fase atual e verifica se algum documento tem resultado == null
    QuerySnapshot snapshot = await _firestore
        .collection('chaveamento')
        .doc(widget.torneioId)
        .collection('fase$faseAtual')
        .get();
    // Retorna true se algum documento tiver o campo resultado como null
    return snapshot.docs.every((doc) => doc['resultado'] == null);
  }

  Future<void> enviarResultados() async {
    //Enviar Resultado para o Banco
=======
  Future<void> enviarResultados() async {
>>>>>>> Stashed changes
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
            .update({
          'resultado': idVencedora,
          'status': 'Finalizado',
        }).then((_) {
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

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Resultados enviados e sorteio realizado para a fase ${faseAtual + 1}!')),
      );
    } else {
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ChaveamentoPage(
                    torneioId: widget.torneioId,
                  )),
        );
      }
    }
  }

  Future<void> carregarDadosIniciais() async {
    // Carrega dados iniciais do torneio e fases
    DocumentSnapshot docTorneio =
        await _firestore.collection('torneios').doc(widget.torneioId).get();

    final chaveamentoRef =
        _firestore.collection('chaveamento').doc(widget.torneioId);
    final chaveamentoSnapshot = await chaveamentoRef.get();
    if (chaveamentoSnapshot.exists) {
      setState(() {
        dadosTorneio = docTorneio;
        isFinalizado = docTorneio['status'] == 'finalizado';
        totalFases = chaveamentoSnapshot.data()!['totalFases'];
      });
    }

    // Carrega a fase inicial
    await _carregarDadosDaFase();
  }
}
