import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/Models/Client.dart' ;
import 'package:flutter_app/pages/clients/AjoutClient.dart';
import 'package:flutter_app/services/client_service.dart';

class ModificationClient extends StatefulWidget {
  final Client client;
  const ModificationClient({super.key ,required this.client });

  @override
  State<ModificationClient> createState() => _ModificationclientState();
}

class _ModificationclientState extends State<ModificationClient> {

  final _formKey = GlobalKey<FormState>();

  // les champs
  var idController = TextEditingController();
  var nomController = TextEditingController();
  var surnomController = TextEditingController() ;
  var numController = TextEditingController() ;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    idController.dispose();
    nomController.dispose();
    surnomController.dispose();
    numController.dispose();
    super.dispose();
  }

  void initState() {
    super.initState();

    // ✅ Initialisation avec les valeurs du client
    idController =  TextEditingController(text: widget.client.id.toString());
    nomController = TextEditingController(text: widget.client.nom);
    surnomController = TextEditingController(text: widget.client.surnom);
    numController = TextEditingController(text: widget.client.num);
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
        title: Text("modification client"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 25), //  marge droite
            child:  TextButton(
              onPressed: () {
                // Validate returns true if the form is valid, or false otherwise.
                if (_formKey.currentState!.validate()) {
                  Client _new_client = new Client( nom: nomController.text, surnom: surnomController.text, num: numController.text) ;
                  ClientService _client_service = new ClientService();
                  _client_service.updateClient(widget.client.id, _new_client.toMap()) ;

                  //  Retour à la page précédente en indiquant succès
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
      body: Container(
        padding: EdgeInsets.all(40),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: idController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Identifiant Client',
                ),
              ),
              SizedBox(height: 15,),
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
      ),
    );
  }
}
