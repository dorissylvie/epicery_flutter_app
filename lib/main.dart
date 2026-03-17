import 'package:flutter/material.dart';
import 'package:flutter_app/pages/accueils/index.dart';
import 'package:flutter_app/pages/clients/index.dart';
import 'package:flutter_app/pages/commandes/index.dart';
import 'package:flutter_app/pages/parametres/index.dart';
import 'package:flutter_app/pages/produits/index.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
        primarySwatch: Colors.pink, // optionnel
        floatingActionButtonTheme : FloatingActionButtonThemeData(
          backgroundColor: Colors.pinkAccent.shade100, // ✅ couleur par défaut
          foregroundColor: Colors.white, // ✅ texte / icônes en blanc
          elevation: 2, // optionnel
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0 ;
  final _pages = [
    AccueilPage(),
    ProduitPage(),
    CommandePage(),
    ClientPage(),
    ParametrePage(),
  ] ;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected:_onItemSelected,
        destinations:[
          NavigationDestination(
              icon: Icon(Icons.home_filled), label: "Accueil"
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag), label: "Produits"
          ),
          NavigationDestination(
              icon: Icon(Icons.list_alt), label: "Commande"
          ),
          NavigationDestination(
              icon: Icon(Icons.group), label: "Clients"
          ),
          NavigationDestination(
              icon: Icon(Icons.settings), label: "Paramètres"
          ),
        ] ,
      ),
    );
  }
  void _onItemSelected(int index){
    setState(() {
      _selectedIndex = index ;
    });
  }
}


