import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:duplacert/pages/Gerenciar_Torneio/torneios.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
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
  TextEditingController numeroParticipantes = TextEditingController();
  TextEditingController dataController = TextEditingController();
  String? estadoSelecionado;
  String? cidadeSelecionada;
  String? categoriaSelecionada = 'Masculino';
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
        title: const Text(
          'Cadastro de Torneio',
          style:
              TextStyle(fontSize: 25, fontFamily: 'inter', color: Colors.black),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(249, 255, 239, 9),
                Color.fromARGB(227, 236, 161, 20),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nomeTorneio,
                decoration: const InputDecoration(labelText: 'Nome do Torneio'),
                validator: (value) =>
                    value!.isEmpty ? 'Digite o nome do torneio' : null,
              ),
              DropdownButtonFormField2<String>(
                isExpanded: true,
                value: estadoSelecionado,
                hint: const Text('Selecione seu Estado'),
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
              const SizedBox(height: 20),
              DropdownButtonFormField2<String>(
                isExpanded: true,
                value: cidadeSelecionada,
                hint: const Text('Selecione uma cidade'),
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
              const SizedBox(height: 20),
              TextFormField(
                controller: numeroParticipantes,
                decoration:
                    const InputDecoration(labelText: 'Número de Participantes'),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter
                      .digitsOnly, // Aceitar apenas números
                ],
                validator: (value) =>
                    value!.isEmpty || int.tryParse(value) == null
                        ? 'Digite um número válido'
                        : null,
              ),
              DropdownButtonFormField<String>(
                value: categoriaSelecionada,
                hint: const Text('Selecione a categoria'),
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
                decoration: const InputDecoration(labelText: 'Categoria'),
              ),
              TextFormField(
                controller: dataController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Selecione uma data',
                ),
                onTap: () => _selecionarData(context),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
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
                child: const Text('Criar Torneio'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return GerenciarTorneios();
            },
          );
        },
        child: const Icon(Icons.add),
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
      if (usuario != null) {
        await _firestore.collection('torneios').add({
          'nome': nomeTorneio.text,
          'estado': estadoSelecionado,
          'cidade': cidadeSelecionada,
          'participantes': int.tryParse(numeroParticipantes.text),
          'categoria': categoriaSelecionada,
          'administrador': usuario.uid,
          'dataTorneio': dataSelecionada,
        });
        Navigator.pop(context);
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
    numeroParticipantes.dispose();
    dataController.dispose();
    super.dispose();
  }
}
