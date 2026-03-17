import 'package:flutter/material.dart' ;
import 'package:flutter_app/Models/Produit.dart' ;
import 'package:flutter_app/pages/produits/AfficheProduit.dart';
import 'package:flutter_app/services/produit_service.dart';
import 'package:flutter_app/pages/produits/AjoutProduit.dart';
class ProduitPage extends StatefulWidget {
  const ProduitPage({super.key});

  @override
  State<ProduitPage> createState() => _ProduitPageState();
}

class _ProduitPageState extends State<ProduitPage> {
  List<Produit> produits = [];
  final ProduitService _produitService = ProduitService();

  @override
  void initState() {
    super.initState();
    _loadProduits(); // charge les données dès le démarrage
  }

  Future<void> _loadProduits() async {
    final data = await _produitService.getAllProduits();
    // 🧠 Transformation de Map → Produit
    final List<Produit> loadedProduits = data.map((map) => Produit.fromMap(map)).toList();
    setState(() {
      produits = loadedProduits;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Appli name") ,
        shadowColor:  Theme.of(context).colorScheme.shadow,
        actions: <Widget>[
          IconButton(
              onPressed: (){},
              icon: const Icon(Icons.notifications))
        ],
        backgroundColor: Colors.transparent,
      ),
      body: ListView.builder(
        itemCount: produits.length,
        padding: const EdgeInsets.all(8.0),
        itemBuilder: (context, index) {
          final produit = produits[index];
          return GestureDetector(
            onTap: () async{
              final result = await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context)=> AfficheProduit(prd : produit!)  )
              );
              _loadProduits();
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                // 👇 Pas de shadow ici
              ),
              child: Row(
                children: [
                  // Avatar avec initiale
                  CircleAvatar(
                    backgroundColor: Colors.pink,
                    child: Text(
                      produit.nomProduit[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Infos produit
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${produit.nomProduit}",
                        style: const TextStyle(fontSize: 18),
                      ),
                      Text(
                        produit.prixUnitaire.toString(),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton (
        onPressed:() async{
          final result = await Navigator.of(context).push(
              MaterialPageRoute(builder: (context)=> const AjoutProduit() )
          );
          if (result == true) {
            // ✅ Rafraîchir les produits
            _loadProduits();

            // ✅ Afficher message de succès
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Produit ajouté avec succès')),
            );
          }
        } ,
        child: Icon(Icons.add ),
      )   ,
    );
  }
}
