import 'package:flutter/material.dart' ;

import 'package:flutter_app/Models/Produit.dart' ;
import 'package:flutter_app/services/produit_service.dart';

class AjoutProduit extends StatefulWidget {
  const AjoutProduit({super.key});

  @override
  State<AjoutProduit> createState() => _AjoutProduitState();
}

class _AjoutProduitState extends State<AjoutProduit> {
  final _formKey = GlobalKey<FormState>();

  // les champs
  final nom_produitController = TextEditingController();
  final prix_unitaireController = TextEditingController() ;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    nom_produitController.dispose();
    prix_unitaireController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.clear), // ❌ icône croix
            onPressed: () {
              Navigator.of(context).pop(); // retour
            },
          ),
          title: Text("ajout produit"),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 25), //  marge droite
              child:  TextButton(
                onPressed: () {
                  // Validate returns true if the form is valid, or false otherwise.
                  if (_formKey.currentState!.validate()) {
                    Produit _new_produit = new Produit(  nom_produit: nom_produitController.text, prix_unitaire: double.parse(prix_unitaireController.text)) ;
                    ProduitService _produit_service = new ProduitService() ;
                    print(_new_produit.prix_unitaire);
                    print(_new_produit.nom_produit);
                    _produit_service.insertProduit(_new_produit.toMap());

                    // ✅ Retour à la page précédente en indiquant succès
                    Navigator.pop(context, true);
                  }
                },
                style:TextButton.styleFrom(
                  backgroundColor: Colors.pink.shade200, // 🎨 couleur de fond
                  foregroundColor: Colors.grey.shade800, // 📝 couleur du texte
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // 🔄 coins arrondis
                  ),
                ) ,
                child: Text("Enregistrer"),
              ),
            )
          ],
        ),
        body : Container(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: nom_produitController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Nom du produit',
                  ),
                  validator: (value){
                    if (value == null || value.isEmpty){
                      return 'Veuillez remplir le nom' ;
                    }
                    return null ;
                  },
                ),
                SizedBox(height: 15,),
                TextFormField(
                  controller: prix_unitaireController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Prix Unitaire',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value){
                    if (value == null || value.isEmpty){
                      return 'Veuillez remplir le nom' ;
                    }
                    if (double.tryParse(value) == null) {
                      return 'Veuillez entrer un nombre valide';
                    }
                    return null ;
                  },
                ),
              ],
            ),
          ),
        )
    ) ;
  }
}
