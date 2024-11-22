import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class buscaFiltro extends StatefulWidget {
  @override
  State<buscaFiltro> createState() => _buscarFiltro();
}

class _buscarFiltro extends State<buscaFiltro> {
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
          'Buscar Torneio',
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
              ElevatedButton(
                onPressed: () {
                  // Fecha o modal antes de chamar a função para evitar problemas com o contexto
                  Map<String, dynamic> filtros = {
                    'nome': nomeTorneio.text.trim(),
                    'participantes': numeroParticipantes,
                    'categoria': categoriaSelecionada?.toString()?.trim(),
                    'uf': estadoSelecionado?.toString()?.trim(),
                    'cidade': cidadeSelecionada?.toString()?.trim(),
                    'data': dataController.text
                        .trim(), // Acesso ao texto do controlador
                  };

// Remover entradas nulas ou vazias
                  filtros.removeWhere((key, value) =>
                      value == null || value.toString().isEmpty);

                  print(filtros);
                  Navigator.pop(context, filtros);
                },
                child: const Text("Buscar"),
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
}
