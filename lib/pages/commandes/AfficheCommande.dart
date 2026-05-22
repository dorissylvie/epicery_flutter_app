import 'package:flutter/material.dart';
import 'package:flutter_app/Models/Commande.dart';
import 'package:flutter_app/services/commande_service.dart';
import 'package:flutter_app/pages/commandes/ModificationCommande.dart';
import 'package:flutter_app/Models/Detail.dart';
import 'package:flutter_app/services/detail_service.dart';
import 'package:flutter_app/services/produit_service.dart';
import 'package:flutter_app/theme/app_colors.dart';

class AfficheCommande extends StatefulWidget {
  final Commande cmd;
  const AfficheCommande({super.key, required this.cmd});

  @override
  State<AfficheCommande> createState() => _AfficheCommandeState();
}

class _AfficheCommandeState extends State<AfficheCommande> {
  Commande? cmd;
  List<Commande> commandes = [];
  final CommandeService _commandeService = CommandeService();

  List<Detail> details = [];
  DetailService detailService = DetailService();
  final ProduitService _produitService = ProduitService();

  double _computeTotal() {
    return details.fold(0.0,
        (previousValue, det) => previousValue + (det.quantite * det.prixReel));
  }

  Future<String> _getProduitNom(int produitId) async {
    try {
      final data = await _produitService.getOneProduit(produitId);
      if (data.isNotEmpty) {
        final map = data.first;
        return map['nom_produit']?.toString() ?? 'Produit #$produitId';
      }
    } catch (_) {}
    return 'Produit #$produitId';
  }

  @override
  void initState() {
    super.initState();
    _loadCommande(); // charge les données dès le démarrage
  }

  Future<void> _loadCommande() async {
    final data = await _commandeService.getOneCommande(widget.cmd.id);
    // Transformation de Map → Commande
    final List<Commande> loadedCommandes =
        data.map((map) => Commande.fromMap(map)).toList();
    setState(() {
      cmd = loadedCommandes.first;
    });
    await _loadDetails(cmd!.id);
  }

  Future<void> _loadDetails(int? commandeId) async {
    if (commandeId == null) {
      return;
    }
    final data = await detailService.getAllDetailsByCommandeId(commandeId);
    final List<Detail> loadedDetails =
        data.map((map) => Detail.fromMap(map)).toList();
    setState(() {
      details = loadedDetails;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            onPressed: () async {
              final result = await Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ModificationCommande(cmd: cmd!)));
              if (result == true) {
                // Rafraîchir les clients
                _loadCommande();
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 10.0),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Text(
                      "ID: ${cmd!.id}",
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      "Compte: ${cmd!.compteId}",
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      "Date: ${cmd!.dateCommande.toLocal()}",
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Padding(
                  padding: EdgeInsets.fromLTRB(20, 30, 20, 0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        const Text(
                          'Détails',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        details.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child:
                                    Text('Aucun détail pour cette commande.'),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: details.length,
                                itemBuilder: (context, index) {
                                  final det = details[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 6.0),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                FutureBuilder<String>(
                                                  future: _getProduitNom(
                                                      det.produitId),
                                                  builder: (context, snap) {
                                                    final name = snap.data ??
                                                        'Chargement...';
                                                    return Text(
                                                      name,
                                                      style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    );
                                                  },
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                    'Quantité: ${det.quantite} ${det.unite}'),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            '${det.prixReel.toStringAsFixed(2)} Ar',
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                        if (details.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${_computeTotal().toStringAsFixed(2)} Ar',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                      ]))
            ],
          ),
        ),
      ),
    );
  }
}
