import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duplacert/models/database.dart';
import 'package:duplacert/models/torneio_model.dart';
import 'package:duplacert/pages/Buscar/buscaCodigo.dart';
import 'package:duplacert/pages/Buscar/buscarFiltro.dart';
import 'package:duplacert/pages/Buscar/entrarTorneio.dart';
import 'package:duplacert/pages/Buscar/torneioCardInsert.dart';
import 'package:duplacert/pages/Config/config.dart';
import 'package:duplacert/pages/Gerenciar_Torneio/torneioCard.dart';
import 'package:flutter/material.dart';

class buscarTorneio extends StatefulWidget {
  @override
  State<buscarTorneio> createState() => _BuscarTorneioState();
}

class _BuscarTorneioState extends State<buscarTorneio> {
  String? imageUrl;
  final TextEditingController codigoTorneio = TextEditingController();
  List<TorneioInsert> torneios = []; // Lista para armazenar os resultados
  List<TorneioInsert> todosTorneios = [];
  bool isLoading = false; // Indicador de carregamento

  @override
  void initState() {
    super.initState();
    LoadUrlImage();
    _getTorneio();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: AppBar(
            toolbarHeight: 60,
            elevation: 6,
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
            title: Stack(
              alignment: Alignment.center,
              children: [
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Buscar Torneios',
                    style: TextStyle(
                      fontSize: 25,
                      fontFamily: 'inter',
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Config(),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(75),
                        child: imageUrl != null
                            ? Image.network(
                                imageUrl!,
                                fit: BoxFit.cover,
                                width: 40,
                                height: 40,
                              )
                            : const Icon(
                                Icons.account_circle,
                                size: 40,
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.5, // 50% da tela
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : torneios.isEmpty
                    ? const Center(child: Text('Nenhum torneio encontrado.'))
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: 15, right: 15),
                        child: ListView.builder(
                          shrinkWrap:
                              true, // Permite que o ListView use apenas o espaço necessário
                          scrollDirection:
                              Axis.horizontal, // Rola horizontalmente
                          itemCount: torneios.length,
                          itemBuilder: (context, index) {
                            return TorneiocardInsert(
                              nome: torneios[index].nome,
                              categoria: torneios[index].categoria,
                              cidade: torneios[index].cidade,
                              estado: torneios[index].estado,
                              numParticipantes:
                                  torneios[index].numParticipantes,
                              idTorneio: torneios[index].idTorneio,
                              dataTorneio: torneios[index].dataTorneio,
                              join: () async {
                                abrirConviteDupla(
                                    context, torneios[index].idTorneio);
                              },
                            );
                          },
                        ),
                      ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final filtros =
                          await showModalBottomSheet<Map<String, dynamic>>(
                        context: context,
                        builder: (context) {
                          return buscaFiltro();
                        },
                      );
                      print('Filtros: $filtros');
                      if (filtros != null) {
                        _aplicarFiltros(filtros);
                      }
                    },
                    child: const Text(
                      'Buscar com filtros',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return BuscaCodigo(
                            onBuscarCodigo: (codigo) async {
                              await buscarPorCodigo(
                                  codigo); // Chama a função necessária após buscar o código
                            },
                          );
                        },
                      );
                    },
                    child: const Text(
                      'Buscar por código',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> buscarPorCodigo(String codigo) async {
    try {
      setState(() => isLoading = true);

      // Busca pelo código do torneio
      torneios = await Torneios().getTorneioById(codigo);
    } catch (error) {
      print("Erro ao buscar o torneio: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar o torneio: $error')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _getTorneio() async {
    try {
      setState(() => isLoading = true);
      final querySnapshot =
          await FirebaseFirestore.instance.collection('torneios').get();

      todosTorneios = querySnapshot.docs.map((doc) {
        return TorneioInsert(
          nome: doc['nome'],
          categoria: doc['categoria'],
          numParticipantes: doc['participantes'],
          dataTorneio: doc['dataTorneio'],
          cidade: doc['cidade'],
          estado: doc['estado'],
          idTorneio: doc.id,
        );
      }).toList();
      print('Todos torneio$todosTorneios');
      torneios = List.from(todosTorneios);
    } catch (error) {
      print("Erro ao carregar torneios: $error");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _aplicarFiltros(Map<String, dynamic> filtros) {
    setState(() {
      torneios = filtros.isEmpty
          ? List.from(todosTorneios)
          : todosTorneios.where((torneio) {
              // Verifica se pelo menos um filtro é satisfeito
              return filtros.entries.any((filtro) {
                final value = filtro.value?.toString();
                if (value == null || value.isEmpty)
                  return false; // Ignora filtros vazios
                final atributo = _getAtributoTorneio(torneio, filtro.key);
                return atributo?.toString() == value;
              });
            }).toList();
    });
  }

  dynamic _getAtributoTorneio(TorneioInsert torneio, String key) {
    switch (key) {
      case 'nome':
        return torneio.nome;
      case 'categoria':
        return torneio.categoria;
      case 'participantes':
        return torneio.numParticipantes;
      case 'data':
        return torneio.dataTorneio;
      case 'cidade':
        return torneio.cidade;
      case 'estado':
        return torneio.estado;
      default:
        return null;
    }
  }

  Future<void> LoadUrlImage() async {
    String? _imageUrl = await DatabaseMethods().checkIfImageExists();
    setState(() {
      imageUrl = _imageUrl;
    });
  }
}
