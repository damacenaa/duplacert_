import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class telaEdicao extends StatefulWidget {
  final String userId;
  final String nomeAtual;
  final String generoAtual;

  const telaEdicao({
    Key? key,
    required this.userId,
    required this.nomeAtual,
    required this.generoAtual,
  }) : super(key: key);

  @override
  State<telaEdicao> createState() => _Telaedicao();
}

class _Telaedicao extends State<telaEdicao> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nomeController;
  String? _genero;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.nomeAtual);
    _genero = widget.generoAtual;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Dados Pessoais'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um nome.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _genero,
                decoration: const InputDecoration(labelText: 'Gênero'),
                items: const [
                  DropdownMenuItem(
                      value: 'Masculino', child: Text('Masculino')),
                  DropdownMenuItem(value: 'Feminino', child: Text('Feminino')),
                  DropdownMenuItem(value: 'Outro', child: Text('Outro')),
                  DropdownMenuItem(
                      value: 'Não definido', child: Text('Não definido')),
                ],
                onChanged: (newValue) {
                  setState(() {
                    _genero = newValue;
                  });
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveChanges,
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await FirebaseFirestore.instance
            .collection('user')
            .doc(widget.userId)
            .update({
          'nome': _nomeController.text,
          'genero': _genero,
        });
        Navigator.pop(context, true);
      } catch (error) {
        print('Erro ao salvar alterações: $error');
      }
    }
  }
}
