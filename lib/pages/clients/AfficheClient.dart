import 'package:flutter/material.dart';
import 'package:flutter_app/Models/Client.dart';
import 'package:flutter_app/Models/Compte.dart';
import 'package:flutter_app/pages/clients/ModificationClient.dart';
import 'package:flutter_app/services/client_service.dart';
import 'package:flutter_app/services/compte_service.dart';

class AfficheClient extends StatefulWidget {
  final Client clt;
  const AfficheClient({super.key, required this.clt});

  @override
  State<AfficheClient> createState() => _AfficheClientState();
}

class _AfficheClientState extends State<AfficheClient> {
  Client? client;
  List<Compte> comptes = [];
  final ClientService _clientService = ClientService();
  CompteService cmptService = CompteService();

  @override
  void initState() {
    super.initState();
    _loadClient();
    // _loadCompte(client); // Charger les données
  }

  Future<void> _loadClient() async {
    final data = await _clientService.getOneClient(widget.clt.id);
    // Transformation de Map → Client
    final List<Client> loadedClients =
        data.map((map) => Client.fromMap(map)).toList();
    setState(() {
      client = loadedClients[0];
    });
    // Charger aussi les comptes du client chargé
    await _loadCompte(client);
  }

  Future<void> _loadCompte(Client? client) async {
    final data = await cmptService.getAllComptesByIClientId(client?.id);

    final List<Compte> loadedComptes =
        data.map((map) => Compte.fromMap(map)).toList();
    setState(() {
      comptes = loadedComptes;
    });
  }

  Future<void> _creerCompte() async {
    if (client == null) return;
    final int id = await cmptService.insertCompte({
      'date_creation': DateTime.now().toIso8601String(),
      'statut': 'actif',
      'client_id': client!.id,
      'frq_id': null,
    });
    // recharger la liste des comptes
    await _loadCompte(client);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Compte créé (id: $id)')),
    );
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
              color: Colors.pink, // Couleur personnalisée si tu veux
              strokeWidth: 4.0, // Épaisseur du cercle
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
                    MaterialPageRoute(
                        builder: (context) =>
                            ModificationClient(client: client!)));
                if (result == true) {
                  // Rafraîchir les clients
                  _loadClient();

                  // Afficher message de succès
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
                onPressed: () {},
                icon: Icon(
                  Icons.star_outline,
                )),
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
                  margin: EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 10.0),
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
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 30, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 0, 0, 25),
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
                        margin: EdgeInsets.fromLTRB(0, 0, 0, 25),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Sexe",
                              style: TextStyle(
                                color: Colors.grey.shade500,
                              ),
                            ),
                            Text(
                              client!.sexe,
                              style: TextStyle(
                                fontSize: 25,
                                color: Colors.grey.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 0, 0, 25),
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
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 0, 0, 25),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Comptes",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey.shade500,
                              ),
                            ),
                            Text(
                              comptes.length.toString(),
                              style: TextStyle(
                                fontSize: 25,
                                color: Colors.grey.shade900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: _creerCompte,
                              icon: const Icon(Icons.add),
                              label: const Text('Ajouter un compte'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.pink.shade200,
                                foregroundColor: Colors.white12,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ListView.builder(
                        itemCount: comptes.length,
                        padding: const EdgeInsets.all(8.0),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final compte = comptes[index];
                          return GestureDetector(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                // Pas de shadow ici
                              ),
                              child: Row(
                                children: [
                                  // Infos client
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "ID: ${compte.id}",
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                      Text(
                                        compte.id.toString(),
                                        style:
                                            const TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
