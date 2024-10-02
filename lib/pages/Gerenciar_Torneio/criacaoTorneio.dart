import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:duplacert/pages/Gerenciar_Torneio/gerenciarTorneios.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class CriarTorneio extends StatefulWidget {
  @override
  State<CriarTorneio> createState() => _CriarTorneio();
}

class _CriarTorneio extends State<CriarTorneio> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>(); // Chave para o formulário
  TextEditingController nomeTorneio = TextEditingController();
  TextEditingController numeroParticipantes = TextEditingController();
  String? estadoSelecionado;
  String? cidadeSelecionada;
  String? categoriaSelecionada = 'Masculino';
  List<String> estados = [];
  List<String> cidades = [];
  bool carregamentoCidades = false;
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
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Form(
          // Aqui envolvemos os campos no Form
          key: _formKey, // Associa o _formKey
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
                items: [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text(
                      'Selecione seu Estado',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  ...estados.map<DropdownMenuItem<String>>((String uf) {
                    return DropdownMenuItem<String>(
                      value: uf,
                      child: Text(uf),
                    );
                  }).toList(),
                ],
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField2<String>(
                isExpanded: true,
                value: cidadeSelecionada,
                hint: const Text('Selecione uma cidade'),
                iconStyleData: const IconStyleData(
                  iconSize: 24,
                ),
                onChanged: (newValue) {
                  setState(() {
                    cidadeSelecionada = newValue!;
                  });
                },
                items: <DropdownMenuItem<String>>[
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Selecione uma cidade',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 17,
                        )),
                  ),
                  ...cidades.map<DropdownMenuItem<String>>((String city) {
                    return DropdownMenuItem<String>(
                      value: city,
                      child: Text(
                        city,
                        style: const TextStyle(fontSize: 17),
                      ),
                    );
                  }).toList(),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: numeroParticipantes,
                decoration:
                    const InputDecoration(labelText: 'Número de Participantes'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty || int.tryParse(value) == null
                        ? 'Digite um número válido'
                        : null,
              ),
              DropdownButtonFormField<String>(
                value: categoriaSelecionada,
                hint: const Text('Selecione a categoria'),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Selecione a categoria'),
                  ),
                  ...['Masculino', 'Feminino', 'Misto'].map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    categoriaSelecionada = value;
                  });
                },
                decoration: const InputDecoration(labelText: 'Categoria'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Valida o formulário aqui
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
        // Verificação para evitar setState após desmontagem
        setState(() {
          estados = data.map((uf) => uf['sigla']).cast<String>().toList();
        });
      }
    } else {
      throw Exception('Falha ao buscar UFs');
    }
  }

  // Carregar a lista de cidades de uma UF específica
  Future<void> carregarCidades(String uf) async {
    final response = await http.get(
      Uri.parse(
          'https://servicodados.ibge.gov.br/api/v1/localidades/estados/$uf/municipios'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (mounted) {
        // Verificação para evitar setState após desmontagem
        setState(() {
          cidades = data.map((city) => city['nome']).cast<String>().toList();
        });
      }
    } else {
      throw Exception('Falha ao buscar cidades');
    }
  }

  @override
  void dispose() {
    nomeTorneio.dispose();
    numeroParticipantes.dispose();
    super.dispose();
  }

  Future<void> criarTorneio() async {
    print("Nome do torneio: ${nomeTorneio.text}");
    print("Categoria: $categoriaSelecionada");
    print("Cidade: $cidadeSelecionada");
    print("Estado: $estadoSelecionado");
    print("Numero de participantes: ${numeroParticipantes.text}");

    // Verificações manuais
    if (estadoSelecionado == null) {
      print("Erro: Estado não selecionado");
      return;
    }

    if (cidadeSelecionada == null) {
      print("Erro: Cidade não selecionada");
      return;
    }

    if (categoriaSelecionada == null) {
      print("Erro: Categoria não selecionada");
      return;
    }

    int? numParticipantes = int.tryParse(numeroParticipantes.text);
    if (numParticipantes == null) {
      print("Erro: Número de participantes inválido");
      return;
    }
    if (_formKey.currentState!.validate()) {
      User? usuario = auth.currentUser;
      if (usuario != null) {
        await FirebaseFirestore.instance.collection('torneios').add({
          'nome': nomeTorneio.text, // Aqui deve-se usar .text
          'estado': estadoSelecionado,
          'cidade': cidadeSelecionada,
          'participantes': numParticipantes, // Verificar se o número é válido
          'categoria': categoriaSelecionada,
          'administrador':
              usuario.uid, // Verifique se o usuário está autenticado
          'criadoEm': Timestamp.now(),
        });
        Navigator.pop(context);
      } else {
        print("Erro: Usuário não autenticado");
      }
    }
  }
}
