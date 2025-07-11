import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/Models/Client.dart' ;
import 'package:flutter_app/services/client_service.dart';

class AjoutClient extends StatefulWidget {
  const AjoutClient({super.key});

  @override
  State<AjoutClient> createState() => _AjoutClientState();
}

class _AjoutClientState extends State<AjoutClient> {
  final _formKey = GlobalKey<FormState>();

  // les champs
  final nomController = TextEditingController();
  final surnomController = TextEditingController() ;
  final numController = TextEditingController() ;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    nomController.dispose();
    surnomController.dispose();
    numController.dispose();
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
          title: Text("ajout client"),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 25), //  marge droite
              child:  TextButton(
                onPressed: () {
                  // Validate returns true if the form is valid, or false otherwise.
                  if (_formKey.currentState!.validate()) {
                    Client _new_client = new Client( nom: nomController.text, surnom: numController.text, num: surnomController.text) ;
                    ClientService _client_service = new ClientService();
                    _client_service.insertClient(_new_client.toMap());

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
                controller: nomController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Nom complet',
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
                controller: surnomController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Surnom',
                ),
                validator: (value){
                  if (value == null || value.isEmpty){
                    return 'Veuillez remplir le nom' ;
                  }
                  return null ;
                },
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: numController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Numero téléphone',
                ),
                validator: (value){
                  if (value == null || value.isEmpty){
                    return 'Veuillez remplir le numéro téléphone' ;
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
