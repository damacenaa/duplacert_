import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:duplacert/models/database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duplacert/pages/Gerenciar_Torneio/torneiosTela.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class CriarTorneio extends StatefulWidget {
  @override
  State<CriarTorneio> createState() => _CriarTorneioState();
}

class _CriarTorneioState extends State<CriarTorneio> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  TextEditingController nomeTorneio = TextEditingController();
  TextEditingController dataController = TextEditingController();
  int? numeroParticipantes;
  String? estadoSelecionado;
  String? cidadeSelecionada;
  String? categoriaSelecionada;
  String? disponTorneio;
  List<String> estados = [];
  List<String> cidades = [];
  bool carregamentoCidades = false;
  DateTime? dataSelecionada;
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    carregarEstados();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Cadastro de Torneio',
          style: TextStyle(
            fontSize: 25,
            fontFamily: 'inter',
            color: Color.fromARGB(255, 20, 20, 20),
          ),
        ),
        centerTitle: true,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  controller: nomeTorneio,
                  decoration: const InputDecoration(
                    labelText: 'Nome do Torneio',
                    labelStyle: TextStyle(fontSize: 17),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Digite o nome do torneio' : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: DropdownButtonFormField<int>(
                  value: numeroParticipantes,
                  hint: const Text(
                    'Numero de duplas',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.normal),
                  ),
                  items: [4, 8, 16, 32].map((numPart) {
                    return DropdownMenuItem(
                      value: numPart,
                      child: Text(numPart.toString()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      numeroParticipantes = value;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Numero de Participantes',
                    labelStyle: TextStyle(fontSize: 17),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: DropdownButtonFormField<String>(
                  value: categoriaSelecionada,
                  hint: const Text(
                    'Selecione a categoria',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.normal),
                  ),
                  items: ['Masculino', 'Feminino', 'Misto'].map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      categoriaSelecionada = value;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Categoria',
                    labelStyle: TextStyle(fontSize: 17),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: DropdownButtonFormField<String>(
                  value: disponTorneio,
                  hint: const Text(
                    'Selecione a disponibilidade',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.normal),
                  ),
                  items: ['Privado', 'Publico'].map((dispon) {
                    return DropdownMenuItem(
                      value: dispon,
                      child: Text(dispon),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      disponTorneio = value;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Disponibilidade',
                    labelStyle: TextStyle(fontSize: 17),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  controller: dataController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Selecione uma data',
                    labelStyle: TextStyle(fontSize: 17),
                  ),
                  onTap: () => _selecionarData(context),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: DropdownButtonFormField2<String>(
                  isExpanded: true,
                  value: estadoSelecionado,
                  hint: const Text(
                    'Selecione seu Estado',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.normal),
                  ),
                  onChanged: (newValue) {
                    setState(() {
                      estadoSelecionado = newValue;
                      cidadeSelecionada = null;
                      carregarCidades(newValue!);
                    });
                  },
                  items: estados.map<DropdownMenuItem<String>>((String uf) {
                    return DropdownMenuItem<String>(
                      value: uf,
                      child: Text(uf),
                    );
                  }).toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: DropdownButtonFormField2<String>(
                  isExpanded: true,
                  value: cidadeSelecionada,
                  hint: const Text(
                    'Selecione uma cidade',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.normal),
                  ),
                  onChanged: (newValue) {
                    setState(() {
                      cidadeSelecionada = newValue;
                    });
                  },
                  items: cidades.map<DropdownMenuItem<String>>((String city) {
                    return DropdownMenuItem<String>(
                      value: city,
                      child: Text(city),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(249, 255, 239, 9),
                        Color.fromARGB(227, 236, 161, 20),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        bool confirmed = await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Confirmar'),
                              content:
                                  const Text('Você deseja criar este torneio?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                  },
                                  child: const Text('Confirmar'),
                                ),
                              ],
                            );
                          },
                        );
                        if (confirmed) {
                          criarTorneio();
                        }
                      }
                    },
                    child: const Text(
                      'Criar Torneio',
                      style: TextStyle(
                        color: Color.fromARGB(253, 8, 8, 8),
                        fontSize: 17,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> carregarEstados() async {
    final response = await http.get(
      Uri.parse('https://servicodados.ibge.gov.br/api/v1/localidades/estados'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (mounted) {
        setState(() {
          estados = data.map((uf) => uf['sigla']).cast<String>().toList();
        });
      }
    } else {
      throw Exception('Falha ao buscar UFs');
    }
  }

  Future<void> carregarCidades(String uf) async {
    final response = await http.get(
      Uri.parse(
          'https://servicodados.ibge.gov.br/api/v1/localidades/estados/$uf/municipios'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (mounted) {
        setState(() {
          cidades = data.map((city) => city['nome']).cast<String>().toList();
        });
      }
    } else {
      throw Exception('Falha ao buscar cidades');
    }
  }

  Future<void> criarTorneio() async {
    if (_formKey.currentState!.validate()) {
      User? usuario = auth.currentUser;
      String codigo = DatabaseMethods().gerarCodigo(10);
      if (usuario != null) {
        await _firestore.collection('torneios').add({
          'nome': nomeTorneio.text,
          'estado': estadoSelecionado,
          'cidade': cidadeSelecionada,
          'participantes': numeroParticipantes,
          'categoria': categoriaSelecionada,
          'administrador': usuario.uid,
          'dataTorneio': dataSelecionada,
          'codigoTorneio': codigo,
          'disponibilidade': disponTorneio,
          'status': 'Inscrições'
        });
        Navigator.pop(context, true);
      } else {
        print("Erro: Usuário não autenticado");
      }
    }
  }

  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      locale: const Locale('pt', 'BR'),
    );

    if (pickedDate != null && pickedDate != dataSelecionada) {
      // Aqui estamos criando uma nova data sem horário
      DateTime dataSemHorario =
          DateTime(pickedDate.year, pickedDate.month, pickedDate.day);

      setState(() {
        dataSelecionada = dataSemHorario; // Atribuímos a data sem horário
        dataController.text =
            "${dataSemHorario.day}/${dataSemHorario.month}/${dataSemHorario.year}"; // Formatação da data
      });
    }
  }

  @override
  void dispose() {
    nomeTorneio.dispose();
    dataController.dispose();
    super.dispose();
  }
}
