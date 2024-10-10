import 'package:duplacert/pages/Visualizar_Torneios/visualizarTorneios.dart';
import 'package:duplacert/pages/Buscar/buscarTorneio.dart';
import 'package:duplacert/pages/Gerenciar_Torneio/torneios.dart';
import 'package:duplacert/pages/Config/config.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutter/material.dart';

class menuPrincipal extends StatefulWidget {
  const menuPrincipal({Key? key}) : super(key: key);

  @override
  _menuPrincipal createState() => _menuPrincipal();
}

class _menuPrincipal extends State<menuPrincipal> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    buscarTorneio(),
    visualizarTorneios(),
    GerenciarTorneios(),
  ];

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: FlashyTabBar(
        selectedIndex: _selectedIndex,
        showElevation: true,
        onItemSelected: (index) => setState(() {
          _selectedIndex = index;
        }),
        items: [
          FlashyTabBarItem(
            activeColor: const Color.fromARGB(
                224, 27, 27, 27), // Define a cor quando ativo
            icon: Icon(
              Icons.search_rounded,
              color: Color.fromARGB(227, 236, 161, 20),
              size: 30,
            ),
            title: Text(
              'Buscar',
              style: TextStyle(fontSize: 15),
            ),
          ),
          FlashyTabBarItem(
            activeColor: const Color.fromARGB(224, 27, 27, 27),
            icon: Icon(
              Icons.workspace_premium_rounded,
              color: Color.fromARGB(227, 236, 161, 20),
              size: 30,
            ),
            title: Text(
              'Meus Torneios',
              style: TextStyle(fontSize: 15),
            ),
          ),
          FlashyTabBarItem(
            activeColor: const Color.fromARGB(224, 27, 27, 27),
            icon: Icon(
              Icons.assignment_rounded,
              color: Color.fromARGB(227, 236, 161, 20),
              size: 30,
            ),
            title: Text(
              'Gerenciar',
              style: TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
