import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/Models/Client.dart' ;
import 'package:flutter_app/pages/clients/AjoutClient.dart';
import 'package:flutter_app/pages/clients/ModificationClient.dart';
import 'package:flutter_app/services/client_service.dart';

class AfficheClient extends StatefulWidget {
  final Client clt;
  const AfficheClient({super.key , required this.clt});

  @override
  State<AfficheClient> createState() => _AfficheClientState();
}

class _AfficheClientState extends State<AfficheClient> {

  Client? client = null ;
  final ClientService _clientService = ClientService();

  @override
  void initState() {
    super.initState();
    _loadClient(); // Charger les données
  }

  Future<void> _loadClient() async {
    final data = await _clientService.getOneClient(widget.clt.id);
    // 🧠 Transformation de Map → Client
    final List<Client> loadedClients = data.map((map) => Client.fromMap(map))
        .toList();
    setState(() {
      client = loadedClients[0];
    });
  }
  @override
  final double fontSize = 60;
  Widget build(BuildContext context) {
    if (client == null) {
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
                    MaterialPageRoute(builder: (context)=> ModificationClient(client : client!) )
                );
                if (result == true) {
                  // ✅ Rafraîchir les clients
                     _loadClient();

                  // ✅ Afficher message de succès
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Client modifié avec succès')),
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
                    client!.nom[0].toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    client!.surnom,
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
                              "Nom Complet",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey.shade500,
                              ),

                            ),
                            Text(
                              client!.nom,
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
                              "Adresse",
                              style: TextStyle(
                                color: Colors.grey.shade500,
                              ),

                            ),
                            Text(
                              "IB 452 / 5200",
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
                              "Téléphone",
                              style: TextStyle(
                                color: Colors.grey.shade500,
                              ),

                            ),
                            Text(
                              client!.num,
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
