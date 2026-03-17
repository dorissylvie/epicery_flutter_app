import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_app/Models/Compte.dart';
import 'package:flutter_app/services/client_service.dart';
import 'package:flutter_app/Models/Client.dart'    ;
import 'package:flutter_app/Models/Produit.dart'    ;
import 'package:flutter_app/services/commande_service.dart';
import 'package:flutter_app/services/compte_service.dart';
import 'package:flutter_app/services/produit_service.dart';

class CommandePage extends StatefulWidget {
  const CommandePage({super.key});

  @override
  State<CommandePage> createState() => _CommandePageState();
}

class _CommandePageState extends State<CommandePage> {
   List<Client> clients = [];
   final ClientService _clientService = ClientService();

   List<Produit> produits = [] ;
   final ProduitService _produitService = ProduitService();

   List<Compte> comptes = [] ;
   CompteService cmptService = CompteService();


   final dropDownKey = GlobalKey<DropdownSearchState>();
   final pdt_dropDownKey = GlobalKey<DropdownSearchState>();

   @override
   void initState() {
     super.initState();
     _loadClients();
     _loadProduits() ; // charge les données dès le démarrage
   }

   Future<void> _loadClients() async {
     final data = await _clientService.getAllClients();
     // Transformation de Map → Client
     final List<Client> loadedClients = data.map((map) => Client.fromMap(map)).toList();
     setState(() {
       clients = loadedClients;
     });
   }

   Future<void> _loadComptes(id) async {
     final data = await  cmptService.getAllComptesByIClientId() ;
     final List<Compte> loadedComptes = data.map((map) => Compte.fromMap(map)).toList();
     setState(() {
       comptes = loadedComptes;
     });
   }

   Future<void> _loadProduits() async {
     final data = await _produitService.getAllProduits();
     //  Transformation de Map → Client
     final List<Produit> loadedProduits = data.map((map) =>
         Produit.fromMap(map)).toList();
     setState(() {
       produits = loadedProduits;
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
      body: Center(
        child: Container(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex:1 ,
                            child:DropdownSearch<Client>(
                              key: dropDownKey,
                              compareFn: (Client a, Client b) => a.id == b.id,
                              items: (filter, infiniteScrollProps) => clients ,
                              itemAsString: (Client item )  => item.nom ,
                              decoratorProps: DropDownDecoratorProps(
                                decoration: InputDecoration(
                                  labelText: 'Client',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              popupProps: PopupProps.bottomSheet(
                                fit: FlexFit.loose,
                                constraints: BoxConstraints(),
                                showSearchBox: true,
                              ),
                              onChanged: (value){
                                if(value != null){
                                  _loadComptes(value.id);
                                }
                              },
                            ),
                          ),//champs pour chercher et selectionner un client
                        ],
                      ),
                    ),
                    Text("Produit"),
                    Container(
                      width: double.infinity,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              flex:3 ,
                              child:DropdownSearch<Produit>(
                                key: pdt_dropDownKey,
                                compareFn: (Produit a, Produit b) => a.id == b.id,
                                items: (filter, infiniteScrollProps) => produits ,
                                itemAsString: (Produit item )  => item.nomProduit ,
                                decoratorProps: DropDownDecoratorProps(
                                  decoration: InputDecoration(
                                    labelText: 'Examples for: ',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                popupProps: PopupProps.bottomSheet(
                                  fit: FlexFit.loose,
                                  constraints: BoxConstraints(),
                                  showSearchBox: true,
                                ),
                              ),
                            ),
                          SizedBox(width: 10),
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              decoration: const InputDecoration(
                                border: OutlineInputBorder() ,
                                labelText: 'Qté',
                              ) ,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              decoration: const InputDecoration(
                                border: OutlineInputBorder() ,
                                labelText: 'Prix',
                              ) ,
                            ),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                            },
                            child: Icon(Icons.add),
                          )
                        ],

                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}



