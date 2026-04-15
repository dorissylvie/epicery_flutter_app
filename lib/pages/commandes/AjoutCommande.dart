import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_app/Models/Compte.dart';
import 'package:flutter_app/Models/Detail.dart';
import 'package:flutter_app/services/client_service.dart';
import 'package:flutter_app/Models/Client.dart';
import 'package:flutter_app/Models/Produit.dart';
import 'package:flutter_app/Models/Commande.dart';
import 'package:flutter_app/services/commande_service.dart';
import 'package:flutter_app/services/compte_service.dart';
import 'package:flutter_app/services/produit_service.dart';
import 'package:flutter_app/services/detail_service.dart';

class AjoutCommande extends StatefulWidget {
  const AjoutCommande({super.key});

  @override
  State<AjoutCommande> createState() => _AjoutCommandeState();
}

class _AjoutCommandeState extends State<AjoutCommande> {
  _AjoutCommandeState();

  List<Client> clients = [];
  final ClientService _clientService = ClientService();

  List<Produit> produits = [];
  final ProduitService _produitService = ProduitService();

  List<Compte> comptes = [];
  CompteService cmptService = CompteService();

  List<Detail> details = [];
  DetailService detailService = DetailService();

  final dropDownKey = GlobalKey<DropdownSearchState>();
  final pdtdropDownKey = GlobalKey<DropdownSearchState>();

  final CommandeService cmdService = CommandeService();
  int? commandeEnCoursId;
  bool _creationCommandeEnCours = false;
  bool _creationCompteEnCours = false;
  Produit? produitSelectionne;
  Client? clientSelectionne;
  Compte? compteSelectionne;
  bool creerNouveauCompteCredit = false;

  // les champs pour les details de la commande
  final qteController = TextEditingController();
  final prixController = TextEditingController();
  final montantPartielController = TextEditingController();

  final List<Map<String, String>> types = [
    {"label": "A payer intégralement", "value": "Complet"},
    {"label": "A payer partiellement", "value": "Partiel"},
    {"label": "A payer par crédit", "value": "Crédit"},
  ];

  String selectedType = 'Complet';

  @override
  void dispose() {
    qteController.dispose();
    prixController.dispose();
    montantPartielController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadClients();
    _loadProduits(); // charge les données dès le démarrage
  }

  Future<void> _loadClients() async {
    final data = await _clientService.getAllClients();
    // Transformation de Map → Client
    final List<Client> loadedClients =
        data.map((map) => Client.fromMap(map)).toList();
    setState(() {
      clients = loadedClients;
    });
  }

  Future<void> _loadComptes(int? id) async {
    if (id == null) {
      setState(() {
        comptes = [];
        compteSelectionne = null;
        creerNouveauCompteCredit = false;
      });
      return;
    }

    final data = await cmptService.getAllComptesByIClientId(id);
    final List<Compte> loadedComptes =
        data.map((map) => Compte.fromMap(map)).toList();
    setState(() {
      comptes = loadedComptes;
      compteSelectionne = null;
      creerNouveauCompteCredit = loadedComptes.isEmpty;
    });
  }

  String _getTypePaiementValue() {
    if (selectedType == 'Partiel') return 'partiel';
    if (selectedType == 'Crédit') return 'credit';
    return 'complet';
  }

  Future<int?> _creerNouveauCompteCredit() async {
    final int? clientId = clientSelectionne?.id;
    if (clientId == null || _creationCompteEnCours) {
      return null;
    }

    _creationCompteEnCours = true;
    try {
      final int compteId = await cmptService.insertCompte({
        'date_creation': DateTime.now().toIso8601String(),
        'statut': 'actif',
        'client_id': clientId,
        'frq_id': null,
      });
      await _loadComptes(clientId);
      return compteId;
    } finally {
      _creationCompteEnCours = false;
    }
  }

  Future<void> _enregistrerCommande() async {
    if (commandeEnCoursId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucune commande a enregistrer')),
      );
      return;
    }

    double resteAPayer = 0.0;
    int? compteId;

    if (selectedType == 'Partiel') {
      final double? montantVerse =
          double.tryParse(montantPartielController.text.trim());
      if (montantVerse == null || montantVerse <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez renseigner un montant partiel valide'),
          ),
        );
        return;
      }
      resteAPayer = totalAPayer - montantVerse;
      if (resteAPayer < 0) {
        resteAPayer = 0;
      }
    }

    if (selectedType == 'Crédit') {
      if (clientSelectionne == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez choisir un client')),
        );
        return;
      }

      if (creerNouveauCompteCredit) {
        compteId = await _creerNouveauCompteCredit();
      } else {
        compteId = compteSelectionne?.id;
      }

      if (compteId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez choisir ou creer un compte de credit'),
          ),
        );
        return;
      }
      resteAPayer = totalAPayer;
    }

    await cmdService.updateCommande(commandeEnCoursId!, {
      'date_commande': DateTime.now().toIso8601String(),
      'type_paiement': _getTypePaiementValue(),
      'total_a_payer': totalAPayer,
      'reste_a_payer': resteAPayer,
      'compte_id': selectedType == 'Crédit' ? compteId : null,
    });

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _loadProduits() async {
    final data = await _produitService.getAllProduits();
    //  Transformation de Map → Client
    final List<Produit> loadedProduits =
        data.map((map) => Produit.fromMap(map)).toList();
    setState(() {
      produits = loadedProduits;
    });
  }

  Future<void> _creerCommande({int? compteId}) async {
    if (commandeEnCoursId != null || _creationCommandeEnCours) {
      return;
    }

    _creationCommandeEnCours = true;
    final commande = Commande(
      dateCommande: DateTime.now(),
      typePaiement: "complet",
      totalAPayer: 0.0,
      resteAPayer: 0.0,
      compteId: compteId,
    );

    try {
      final id = await cmdService.insertCommande(commande.toMap());
      if (!mounted) return;
      setState(() {
        commandeEnCoursId = id;
      });
      await _loadDetails();
    } finally {
      _creationCommandeEnCours = false;
    }
  }

  Future<void> _loadDetails() async {
    if (commandeEnCoursId == null) {
      return;
    }

    final data =
        await detailService.getAllDetailsByCommandeId(commandeEnCoursId!);
    final List<Detail> loadedDetails =
        data.map((map) => Detail.fromMap(map)).toList();
    setState(() {
      details = loadedDetails;
    });
  }

  double get totalAPayer {
    return details.fold(
      0.0,
      (sum, detail) => sum + (detail.quantite * detail.prixReel),
    );
  }

  String _getNomProduitById(int produitId) {
    for (final produit in produits) {
      if (produit.id == produitId) {
        return produit.nomProduit;
      }
    }
    return 'Produit #$produitId';
  }

  Future<void> _supprimerDetail(Detail detail) async {
    if (detail.id == null) return;
    await detailService.deleteDetail(detail.id!);
    await _loadDetails();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Detail supprime')),
    );
  }

  Future<void> _modifierDetail(Detail detail) async {
    if (detail.id == null) return;

    final qteEditController =
        TextEditingController(text: detail.quantite.toString());
    final prixEditController =
        TextEditingController(text: detail.prixReel.toString());

    final bool? valider = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modifier detail'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: qteEditController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Qte'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: prixEditController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Prix'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );

    if (valider != true) {
      qteEditController.dispose();
      prixEditController.dispose();
      return;
    }

    final qte = double.tryParse(qteEditController.text.trim());
    final prix = double.tryParse(prixEditController.text.trim());

    qteEditController.dispose();
    prixEditController.dispose();

    if (qte == null || prix == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Valeurs invalides pour qte/prix')),
      );
      return;
    }

    await detailService.updateDetail(detail.id!, {
      'quantite': qte,
      'prix_reel': prix,
      'unite': detail.unite,
      'commande_id': detail.commandeId,
      'produit_id': detail.produitId,
    });
    await _loadDetails();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Detail modifie')),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double headerHeight = 44;
    const double rowHeight = 52;
    const double emptyStateHeight = 96;
    final double maxTableHeight = MediaQuery.of(context).size.height * 0.45;
    final double rawTableHeight = details.isEmpty
        ? emptyStateHeight
        : headerHeight + 8 + (details.length * rowHeight);
    final double detailsTableHeight =
        rawTableHeight.clamp(140.0, maxTableHeight);

    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              Navigator.of(context).pop(); // Retour
            },
          ),
          title: const Text("Ajout commande"),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 25),
              child: TextButton(
                onPressed: _enregistrerCommande,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.pink.shade200,
                  foregroundColor: Colors.grey.shade800,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text("Enregistrer"),
              ),
            ),
          ]),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownSearch<Client>(
                key: dropDownKey,
                compareFn: (Client a, Client b) => a.id == b.id,
                items: (filter, infiniteScrollProps) => clients,
                itemAsString: (Client item) => item.nom,
                decoratorProps: const DropDownDecoratorProps(
                  decoration: InputDecoration(
                    labelText: 'Client',
                    border: OutlineInputBorder(),
                  ),
                ),
                popupProps: const PopupProps.bottomSheet(
                  fit: FlexFit.loose,
                  constraints: BoxConstraints(),
                  showSearchBox: true,
                ),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      clientSelectionne = value;
                    });
                    _loadComptes(value.id);
                  }
                },
              ),
              const SizedBox(height: 12),
              const Text("Produit"),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: DropdownSearch<Produit>(
                      key: pdtdropDownKey,
                      compareFn: (Produit a, Produit b) => a.id == b.id,
                      items: (filter, infiniteScrollProps) => produits,
                      itemAsString: (Produit item) => item.nomProduit,
                      decoratorProps: const DropDownDecoratorProps(
                        decoration: InputDecoration(
                          labelText: 'Produit',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      popupProps: const PopupProps.bottomSheet(
                        fit: FlexFit.loose,
                        constraints: BoxConstraints(),
                        showSearchBox: true,
                      ),
                      onChanged: (Produit? value) {
                        setState(() {
                          produitSelectionne = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: qteController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Qte',
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez remplir la quantite';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Veuillez entrer un nombre valide';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: prixController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Prix',
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez remplir le prix';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Veuillez entrer un nombre valide';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (commandeEnCoursId == null) {
                          await _creerCommande();
                          if (commandeEnCoursId == null) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Erreur lors de la creation de la commande'),
                              ),
                            );
                            return;
                          }
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Commande creee (id: $commandeEnCoursId)',
                              ),
                            ),
                          );
                        }

                        final int? produitId = produitSelectionne?.id;
                        if (produitId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Veuillez selectionner un produit'),
                            ),
                          );
                          return;
                        }

                        if (pdtdropDownKey.currentState != null) {
                          final detail = Detail(
                            quantite: double.parse(qteController.text),
                            prixReel: double.parse(prixController.text),
                            unite: "unite",
                            commandeId: commandeEnCoursId!,
                            produitId: produitId,
                          );

                          await detailService.insertDetail(detail.toMap());
                          await _loadDetails();

                          pdtdropDownKey.currentState?.changeSelectedItem(null);
                          setState(() {
                            produitSelectionne = null;
                          });
                        }
                      },
                      child: const Icon(Icons.add),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),
              const Text("Details de la commande"),
              const SizedBox(height: 8),
              SizedBox(
                height: detailsTableHeight,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.pink.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Expanded(flex: 4, child: Text('Produit')),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Qte',
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Prix',
                                textAlign: TextAlign.right,
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Montant',
                                textAlign: TextAlign.right,
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Actions',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: details.isEmpty
                            ? const Center(
                                child:
                                    Text('Aucun detail ajoute pour le moment'),
                              )
                            : ListView.builder(
                                itemCount: details.length,
                                itemBuilder: (context, index) {
                                  final detail = details[index];
                                  final montant =
                                      detail.quantite * detail.prixReel;

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                      horizontal: 8,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 4,
                                          child: Text(
                                            _getNomProduitById(
                                                detail.produitId),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            detail.quantite.toStringAsFixed(2),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            '${detail.prixReel.toStringAsFixed(2)} Ar',
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            '${montant.toStringAsFixed(2)} Ar',
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit,
                                                    size: 18),
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(
                                                  minWidth: 30,
                                                  minHeight: 30,
                                                ),
                                                visualDensity:
                                                    VisualDensity.compact,
                                                onPressed: () {
                                                  _modifierDetail(detail);
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete,
                                                    size: 18,
                                                    color: Colors.red),
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(
                                                  minWidth: 30,
                                                  minHeight: 30,
                                                ),
                                                visualDensity:
                                                    VisualDensity.compact,
                                                onPressed: () {
                                                  _supprimerDetail(detail);
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Total a payer',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      '${totalAPayer.toStringAsFixed(2)} Ar',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField(
                  decoration: const InputDecoration(
                    labelText: 'Type de paiement',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedType,
                  items: types
                      .map((type) => DropdownMenuItem(
                          value: type['value'], child: Text(type['label']!)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedType = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez choisir un type de paiement';
                    }
                    return null;
                  }),
              const SizedBox(height: 10),
              if (selectedType == 'Partiel') ...[
                TextFormField(
                  controller: montantPartielController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Montant a payer maintenant',
                    hintText: 'Ex: 10000',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 10),
              ],
              if (selectedType == 'Crédit') ...[
                if (clientSelectionne == null)
                  const Text(
                    'Choisissez d\'abord un client pour voir ses comptes.',
                    style: TextStyle(color: Colors.black54),
                  ),
                if (clientSelectionne != null)
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Ajouter un nouveau compte'),
                    subtitle: Text(
                      comptes.isEmpty
                          ? 'Ce client n\'a pas encore de compte.'
                          : 'Activez si vous voulez creer un nouveau compte.',
                    ),
                    value: creerNouveauCompteCredit,
                    onChanged: (value) {
                      setState(() {
                        creerNouveauCompteCredit = value;
                        if (value) {
                          compteSelectionne = null;
                        }
                      });
                    },
                  ),
                if (clientSelectionne != null &&
                    !creerNouveauCompteCredit &&
                    comptes.isNotEmpty)
                  DropdownSearch<Compte>(
                    compareFn: (Compte a, Compte b) => a.id == b.id,
                    selectedItem: compteSelectionne,
                    items: (filter, infiniteScrollProps) => comptes,
                    itemAsString: (Compte item) =>
                        'Compte #${item.id} - ${item.statut}',
                    decoratorProps: const DropDownDecoratorProps(
                      decoration: InputDecoration(
                        labelText: 'Compte credit',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    popupProps: const PopupProps.bottomSheet(
                      fit: FlexFit.loose,
                      constraints: BoxConstraints(),
                      showSearchBox: false,
                    ),
                    onChanged: (value) {
                      setState(() {
                        compteSelectionne = value;
                      });
                    },
                  ),
                if (clientSelectionne != null && creerNouveauCompteCredit)
                  const Text(
                    'Un nouveau compte sera cree a l\'enregistrement de la commande.',
                    style: TextStyle(color: Colors.black54),
                  ),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
