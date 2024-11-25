import 'dart:async';
import 'package:duplacert/models/torneio_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MeuTorneio extends StatefulWidget {
  final String torneioId;

  MeuTorneio({required this.torneioId});

  @override
  _meuTorneio createState() => _meuTorneio();
}

class _meuTorneio extends State<MeuTorneio> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int faseAtual = 1;
  int totalFases = 1;
  Map<String, List<String>> nomesDuplas = {};
  Map<String, String?> resultadosPartidas = {};
  bool carregandoNomes = true;
  bool isFinalizado = false;
  DocumentSnapshot? dadosTorneio;

  @override
  void initState() {
    super.initState();
    carregarDadosIniciais();
  }

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
            IconButton(icon: Icon(Icons.arrow_back), onPressed: faseAnterior),
            IconButton(icon: Icon(Icons.arrow_forward), onPressed: proximaFase),
          ],
        ),
        body: carregandoNomes
            ? Center(child: CircularProgressIndicator())
            : confrontoLayout(),
      );
    }
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

  void proximaFase() {
    if (faseAtual < totalFases) {
      setState(() {
        faseAtual++;
        nomesDuplas.clear();
      });
      resultadosPartidas = {};
      _carregarDadosDaFase();
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
      });
      resultadosPartidas = {};
      _carregarDadosDaFase();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Já estamos na primeira fase!')),
      );
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

  Future<void> _carregarDadosDaFase() async {
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
    for (String idDupla in idsDuplas) {
      await Torneios().getDupla(idDupla, (nome1, nome2) {
        setState(() {
          nomesDuplas[idDupla] = [nome1, nome2];
        });
      });
    }
  }
}
