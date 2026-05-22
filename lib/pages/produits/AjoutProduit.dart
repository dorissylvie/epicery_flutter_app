import 'package:flutter/material.dart' ;

import 'package:flutter_app/Models/Produit.dart' ;
import 'package:flutter_app/services/produit_service.dart';
import 'package:flutter_app/theme/app_colors.dart';

class AjoutProduit extends StatefulWidget {
  const AjoutProduit({super.key});

  @override
  State<AjoutProduit> createState() => _AjoutProduitState();
}

class _AjoutProduitState extends State<AjoutProduit> {
  final _formKey = GlobalKey<FormState>();

  // les champs
  final nomProduitController = TextEditingController();
  final prixUnitaireController = TextEditingController();
  final prixPaquetController = TextEditingController();

  String selectedCtgr = '0' ;

  final List<Map<String, String>> ctgrs = [
    {"label": "BISC", "value": "0"},
    {"label": "HUI", "value": "1"},
  ];


  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    nomProduitController.dispose();
    prixUnitaireController.dispose();
    prixPaquetController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.clear),
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
                    Produit newProduit = Produit(
                      nomProduit: nomProduitController.text,
                      prixUnitaire: double.parse(prixUnitaireController.text),
                      prixPaquet: double.parse(prixPaquetController.text),
                      photoProduit: '',
                      ctgrId: int.parse(selectedCtgr),
                    ) ;
                    ProduitService produitService =  ProduitService() ;
                    produitService.insertProduit(newProduit.toMap());

                    //  Retour à la page précédente en indiquant succès
                    Navigator.pop(context, true);
                  }
                },
                style:TextButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.onAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
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
                  controller: nomProduitController,
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
                  controller: prixUnitaireController,
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
                SizedBox(height: 15,),
                TextFormField(
                  controller: prixPaquetController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Prix d\'un paquet',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value){
                    if (value == null || value.isEmpty){
                      return 'Veuillez renseigner le prix' ;
                    }
                    if (double.tryParse(value) == null) {
                      return 'Veuillez entrer un nombre valide';
                    }
                    return null ;
                  },
                ),
                SizedBox(height: 15,),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Sexe',
                  ),
                  value: selectedCtgr,
                  items: ctgrs.map((ctgr) => DropdownMenuItem(
                      value : ctgr['value'] ,
                      child : Text(ctgr['label']!)
                  )).toList(),
                  onChanged: (String? value){
                    setState(() {
                      selectedCtgr = value !;
                    });
                  },
                  validator: (value){
                    if (value == null || value.isEmpty) {
                      return 'Veuillez choisir un sexe';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        )
    ) ;
  }
}
