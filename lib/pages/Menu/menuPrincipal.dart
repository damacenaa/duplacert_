import 'package:duplacert/pages/Criar_Torneio/criarTorneio.dart';
import 'package:duplacert/pages/Menu/config.dart';
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
    criarTorneio(),
    SearchScreen(),
    HighlightsScreen(),
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
            icon: Icon(Icons.event),
            title: Text('Events'),
          ),
          FlashyTabBarItem(
            icon: Icon(Icons.search),
            title: Text('Search'),
          ),
          FlashyTabBarItem(
            icon: Icon(Icons.highlight),
            title: Text('Highlights'),
          ),
        ],
      ),
    );
  }
}

class SearchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Search Screen'),
    );
  }
}

class HighlightsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Highlights Screen'),
    );
  }
}
