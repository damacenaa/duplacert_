import 'package:flutter/material.dart';

class BuscaCodigo extends StatelessWidget {
  final Function(String) onBuscarCodigo;

  const BuscaCodigo({required this.onBuscarCodigo, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController codigoController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Digite o código do torneio",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: codigoController,
            decoration: const InputDecoration(
              labelText: 'Código do Torneio',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: () {
                  String codigo = codigoController.text.trim();
                  if (codigo.isNotEmpty) {
                    // Fecha o modal antes de chamar a função para evitar problemas com o contexto
                    Navigator.of(context).pop();
                    onBuscarCodigo(codigo);
                  }
                },
                child: const Text("Buscar"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
