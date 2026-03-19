import 'package:flutter/material.dart';
import 'screens/belanja_page.dart';
import 'screens/artikel_page.dart';
import 'screens/tren_harga_page.dart';
import 'screens/favorit_page.dart';
import 'widgets/navbar_widget.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    BelanjaPage(),
    ArtikelPage(),
    TrenHargaPage(),
    FavoritPage(),
  ];

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavbarWidget(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onTabSelected,
      ),
    );
  }
}
