import 'package:flutter/material.dart';
import 'package:flutter_app/Models/Commande.dart';
import 'package:flutter_app/services/commande_service.dart';
import 'package:flutter_app/pages/commandes/AjoutCommande.dart';
import 'package:flutter_app/pages/commandes/AfficheCommande.dart';

class CommandePage extends StatefulWidget {
  const CommandePage({super.key});

  @override
  State<CommandePage> createState() => _CommandePageState();
}

class _CommandePageState extends State<CommandePage> {
  List<Commande> commandes = [];
  final CommandeService _commandeService = CommandeService();

  @override
  void initState() {
    super.initState();
    _loadCommandes(); // charge les données dès le démarrage
  }

  Future<void> _loadCommandes() async {
    final data = await _commandeService.getAllCommandes();
    // Transformation de Map → Commande
    final List<Commande> loadedCommandes =
        data.map((map) => Commande.fromMap(map)).toList();
    setState(() {
      commandes = loadedCommandes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Appli name"),
        shadowColor: Theme.of(context).colorScheme.shadow,
        actions: <Widget>[
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications))
        ],
        backgroundColor: Colors.transparent,
      ),
      body: ListView.builder(
        itemCount: commandes.length,
        padding: const EdgeInsets.all(8.0),
        itemBuilder: (context, index) {
          final commande = commandes[index];
          return GestureDetector(
            onTap: () async {
              final result = await Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => AfficheCommande(cmd: commande!)));
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ID Commande : ${commande.id}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Date : ${commande.dateCommande.toLocal()}',
                      style: const TextStyle(fontSize: 14)),
                  Text('Type de paiement : ${commande.typePaiement}',
                      style: const TextStyle(fontSize: 14)),
                  Text('Total à payer : ${commande.totalAPayer} DH',
                      style: const TextStyle(fontSize: 14)),
                  Text('Reste à payer : ${commande.resteAPayer} DH',
                      style: const TextStyle(fontSize: 14)),
                  Text('Compte ID : ${commande.compteId}',
                      style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AjoutCommande()));
          if (result == true) {
            _loadCommandes();
            // Afficher message de succès
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Commande ajoutée avec succès')),
            );
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
