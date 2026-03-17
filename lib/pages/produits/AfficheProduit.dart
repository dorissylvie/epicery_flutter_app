import 'package:flutter/material.dart';
import 'package:flutter_app/Models/Produit.dart' ;
import 'package:flutter_app/pages/produits/ModificationProduit.dart';
import 'package:flutter_app/services/produit_service.dart';

class AfficheProduit extends StatefulWidget {
  final Produit prd;
  const AfficheProduit({super.key , required this.prd});

  @override
  State<AfficheProduit> createState() => _AfficheProduitState();
}

class _AfficheProduitState extends State<AfficheProduit> {

  Produit? produit = null ;
  final ProduitService _produitService = ProduitService();

  @override
  void initState() {
    super.initState();
    _loadProduit(); // Charger les données
  }

  Future<void> _loadProduit() async {
    final data = await _produitService.getOneProduit(widget.prd.id);
    // Transformation de Map →Produit
    final List<Produit> loadedProduits = data.map((map) =>Produit.fromMap(map))
        .toList();
    setState(() {
      produit = loadedProduits[0];
    });
  }
  @override
  final double fontSize = 60;
  Widget build(BuildContext context) {
    if (produit == null) {
      // ⏳ Affiche un loader pendant le chargement
      return Scaffold(
        body: Container(
          color: Colors.grey.shade200, // 🌫️ Fond gris clair
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.pink, // 🎨 Couleur personnalisée si tu veux
              strokeWidth: 4.0,   // 🔄 Épaisseur du cercle
            ),
          ),
        ),

      );
    }
    return Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              onPressed: () async {
                final result = await Navigator.of(context).push(
                    MaterialPageRoute(builder: (context)=> ModificationProduit(produit : produit!) )
                );
                if (result == true) {
                  // ✅ Rafraîchir les produits
                  _loadProduit();

                  // ✅ Afficher message de succès
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Produit modifié avec succès')),
                  );
                }
              },
              icon: Icon(
                Icons.edit_outlined,
              ),
            ),
            IconButton(
                onPressed: (){},
                icon: Icon(
                  Icons.star_outline,
                )
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  margin : EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 10.0) ,
                  width: fontSize * 2,
                  height: fontSize * 2,
                  decoration: const BoxDecoration(
                    color: Colors.pink,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    produit!.nomProduit[0].toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    produit!.nomProduit,
                    overflow: TextOverflow.ellipsis,
                    style : TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                Padding(
                  padding : EdgeInsets.fromLTRB(20, 30, 20, 0),
                  child:Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin : EdgeInsets.fromLTRB(0,0,0,25),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Prix unitaire",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey.shade500,
                              ),

                            ),
                            Text(
                              produit!.prixUnitaire.toString(),
                              style: TextStyle(
                                fontSize: 25,
                                color: Colors.grey.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin : EdgeInsets.fromLTRB(0,0,0,25),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Prix Paquet",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey.shade500,
                              ),

                            ),
                            Text(
                              produit!.prixPaquet.toString(),
                              style: TextStyle(
                                fontSize: 25,
                                color: Colors.grey.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin : EdgeInsets.fromLTRB(0,0,0,25),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Catégorie",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey.shade500,
                              ),

                            ),
                            Text(
                              produit!.ctgrId.toString(),
                              style: TextStyle(
                                fontSize: 25,
                                color: Colors.grey.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ) ,
                )
              ],
            ),
          ),
        )
    );
  }
}
