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
import 'package:flutter_app/theme/app_colors.dart';

InputDecoration _fieldDecor(String label, {String? hint}) => InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
    );

Widget _sectionLabel(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
          color: AppColors.textSecondary,
        ),
      ),
    );
// ──────────────────────────────────────────────────────────────────────────────

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

  final qteController = TextEditingController();
  final prixController = TextEditingController();
  final montantPartielController = TextEditingController();

  final List<Map<String, String>> types = [
    {"label": "Paiement intégral", "value": "Complet"},
    {"label": "Paiement partiel", "value": "Partiel"},
    {"label": "Paiement par crédit", "value": "Crédit"},
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
    _loadProduits();
  }

  Future<void> _loadClients() async {
    final data = await _clientService.getAllClients();
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
    if (clientId == null || _creationCompteEnCours) return null;
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
        const SnackBar(content: Text('Aucune commande à enregistrer')),
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
              content: Text('Veuillez renseigner un montant partiel valide')),
        );
        return;
      }
      resteAPayer = totalAPayer - montantVerse;
      if (resteAPayer < 0) resteAPayer = 0;
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
              content: Text('Veuillez choisir ou créer un compte de crédit')),
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
    final List<Produit> loadedProduits =
        data.map((map) => Produit.fromMap(map)).toList();
    setState(() {
      produits = loadedProduits;
    });
  }

  Future<void> _creerCommande({int? compteId}) async {
    if (commandeEnCoursId != null || _creationCommandeEnCours) return;
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
    if (commandeEnCoursId == null) return;
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
        0.0, (sum, detail) => sum + (detail.quantite * detail.prixReel));
  }

  String _getNomProduitById(int produitId) {
    for (final produit in produits) {
      if (produit.id == produitId) return produit.nomProduit;
    }
    return 'Produit #$produitId';
  }

  Future<void> _supprimerDetail(Detail detail) async {
    if (detail.id == null) return;
    await detailService.deleteDetail(detail.id!);
    await _loadDetails();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Détail supprimé')),
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
          backgroundColor: AppColors.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Modifier le détail',
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: qteEditController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: _fieldDecor('Quantité'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: prixEditController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: _fieldDecor('Prix unitaire'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.onAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
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
        const SnackBar(content: Text('Valeurs invalides pour qté/prix')),
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
      const SnackBar(content: Text('Détail modifié')),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    const double headerHeight = 44;
    const double rowHeight = 52;
    const double emptyStateHeight = 96;
    final double maxTableHeight = MediaQuery.of(context).size.height * 0.40;
    final double rawTableHeight = details.isEmpty
        ? emptyStateHeight
        : headerHeight + 8 + (details.length * rowHeight);
    final double detailsTableHeight =
        rawTableHeight.clamp(140.0, maxTableHeight);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Nouvelle commande',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: FilledButton(
              onPressed: _enregistrerCommande,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.onAccent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                textStyle: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13.5),
              ),
              child: const Text('Enregistrer'),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Section Client ─────────────────────────────────────────────
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('Client'),
                    DropdownSearch<Client>(
                      key: dropDownKey,
                      compareFn: (a, b) => a.id == b.id,
                      items: (filter, _) => clients,
                      itemAsString: (c) => c.nom,
                      decoratorProps: DropDownDecoratorProps(
                        decoration: _fieldDecor('Rechercher un client…'),
                      ),
                      popupProps: const PopupProps.bottomSheet(
                        fit: FlexFit.loose,
                        constraints: BoxConstraints(),
                        showSearchBox: true,
                      ),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => clientSelectionne = value);
                          _loadComptes(value.id);
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Section Ajout produit ──────────────────────────────────────
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('Ajouter un produit'),
                    DropdownSearch<Produit>(
                      key: pdtdropDownKey,
                      compareFn: (a, b) => a.id == b.id,
                      items: (filter, _) => produits,
                      itemAsString: (p) => p.nomProduit,
                      decoratorProps: DropDownDecoratorProps(
                        decoration: _fieldDecor('Rechercher un produit…'),
                      ),
                      popupProps: const PopupProps.bottomSheet(
                        fit: FlexFit.loose,
                        constraints: BoxConstraints(),
                        showSearchBox: true,
                      ),
                      onChanged: (value) =>
                          setState(() => produitSelectionne = value),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: qteController,
                            decoration: _fieldDecor('Quantité'),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: prixController,
                            decoration: _fieldDecor('Prix unitaire (Ar)'),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 50,
                          width: 50,
                          child: FilledButton(
                            onPressed: () async {
                              if (commandeEnCoursId == null) {
                                await _creerCommande();
                                if (commandeEnCoursId == null) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Erreur lors de la création de la commande')),
                                  );
                                  return;
                                }
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Commande créée (id: $commandeEnCoursId)')),
                                );
                              }

                              final int? produitId = produitSelectionne?.id;
                              if (produitId == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Veuillez sélectionner un produit')),
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
                                await detailService
                                    .insertDetail(detail.toMap());
                                await _loadDetails();
                                pdtdropDownKey.currentState
                                    ?.changeSelectedItem(null);
                                qteController.clear();
                                prixController.clear();
                                setState(() => produitSelectionne = null);
                              }
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Icon(Icons.add_rounded,
                              color: AppColors.onAccent),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Section Détails ────────────────────────────────────────────
              _card(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                      child: Row(
                        children: [
                          _sectionLabel('Détails de la commande'),
                          const Spacer(),
                          if (details.isNotEmpty)
                            Text(
                              '${details.length} ligne${details.length > 1 ? 's' : ''}',
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.textSecondary),
                            ),
                        ],
                      ),
                    ),

                    // Table header
                    Container(
                      color: AppColors.tableHeader,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: const Row(
                        children: [
                          Expanded(
                              flex: 3,
                              child: Text('Produit', style: _tableHeaderStyle)),
                          Expanded(
                              flex: 2,
                              child: Text('Qté',
                                  textAlign: TextAlign.center,
                                  style: _tableHeaderStyle)),
                          Expanded(
                              flex: 3,
                              child: Text('Prix',
                                  textAlign: TextAlign.right,
                                  style: _tableHeaderStyle)),
                          Expanded(
                              flex: 3,
                              child: Text('Montant',
                                  textAlign: TextAlign.right,
                                  style: _tableHeaderStyle)),
                          Expanded(flex: 2, child: SizedBox()),
                        ],
                      ),
                    ),

                    SizedBox(
                      height: detailsTableHeight,
                      child: details.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.receipt_long_outlined,
                                      size: 32, color: AppColors.border),
                                  SizedBox(height: 8),
                                  Text('Aucun produit ajouté',
                                      style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 13)),
                                ],
                              ),
                            )
                          : ListView.separated(
                              padding: EdgeInsets.zero,
                              itemCount: details.length,
                              separatorBuilder: (_, __) => const Divider(
                                  height: 1, color: AppColors.border, indent: 16),
                              itemBuilder: (context, index) {
                                final detail = details[index];
                                final montant =
                                    detail.quantite * detail.prixReel;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          _getNomProduitById(detail.produitId),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              color: AppColors.textPrimary),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          detail.quantite.toStringAsFixed(2),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              color: AppColors.textSecondary),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          '${detail.prixReel.toStringAsFixed(2)} Ar',
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              color: AppColors.textSecondary),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          '${montant.toStringAsFixed(2)} Ar',
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            _iconAction(
                                              icon: Icons.edit_outlined,
                                              color: AppColors.textSecondary,
                                              onTap: () =>
                                                  _modifierDetail(detail),
                                            ),
                                            _iconAction(
                                              icon: Icons.delete_outline,
                                              color: AppColors.danger,
                                              onTap: () =>
                                                  _supprimerDetail(detail),
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

                    // Total row
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(top: BorderSide(color: AppColors.border)),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          const Text('Total à payer',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                  fontSize: 14)),
                          const Spacer(),
                          Text(
                            '${totalAPayer.toStringAsFixed(2)} Ar',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Section Paiement ───────────────────────────────────────────
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('Mode de paiement'),
                    DropdownButtonFormField<String>(
                      decoration: _fieldDecor('Type de paiement'),
                      value: selectedType,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded,
                          color: AppColors.textSecondary),
                      style:
                          const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                      dropdownColor: AppColors.surface,
                      items: types
                          .map((type) => DropdownMenuItem(
                                value: type['value'],
                                child: Text(type['label']!),
                              ))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => selectedType = value!),
                    ),
                    if (selectedType == 'Partiel') ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: montantPartielController,
                        decoration: _fieldDecor('Montant versé maintenant',
                            hint: 'Ex: 10 000'),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                      ),
                    ],
                    if (selectedType == 'Crédit') ...[
                      const SizedBox(height: 12),
                      if (clientSelectionne == null)
                        _infoBox(
                            'Sélectionnez d\'abord un client pour voir ses comptes.'),
                      if (clientSelectionne != null) ...[
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Créer un nouveau compte',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w500)),
                          subtitle: Text(
                            comptes.isEmpty
                                ? 'Ce client n\'a pas encore de compte.'
                                : 'Activez pour ouvrir un nouveau compte.',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textSecondary),
                          ),
                          value: creerNouveauCompteCredit,
                          activeColor: AppColors.accent,
                          onChanged: (value) {
                            setState(() {
                              creerNouveauCompteCredit = value;
                              if (value) compteSelectionne = null;
                            });
                          },
                        ),
                        if (!creerNouveauCompteCredit &&
                            comptes.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          DropdownSearch<Compte>(
                            compareFn: (a, b) => a.id == b.id,
                            selectedItem: compteSelectionne,
                            items: (filter, _) => comptes,
                            itemAsString: (c) =>
                                'Compte #${c.id} — ${c.statut}',
                            decoratorProps: DropDownDecoratorProps(
                              decoration: _fieldDecor('Compte de crédit'),
                            ),
                            popupProps: const PopupProps.bottomSheet(
                              fit: FlexFit.loose,
                              constraints: BoxConstraints(),
                              showSearchBox: false,
                            ),
                            onChanged: (value) =>
                                setState(() => compteSelectionne = value),
                          ),
                        ],
                        if (creerNouveauCompteCredit)
                          _infoBox(
                              'Un nouveau compte sera créé à l\'enregistrement de la commande.'),
                      ],
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────────

const _tableHeaderStyle = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w700,
  letterSpacing: 0.4,
  color: AppColors.textSecondary,
);

Widget _card({required Widget child, EdgeInsets? padding}) {
  return Container(
    width: double.infinity,
    padding: padding ?? const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border),
    ),
    child: child,
  );
}

Widget _iconAction({
  required IconData icon,
  required Color color,
  required VoidCallback onTap,
}) {
  return InkWell(
    borderRadius: BorderRadius.circular(8),
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.all(2),
      child: Icon(icon, size: 16, color: color),
    ),
  );
}

Widget _infoBox(String text) {
  return Container(
    margin: const EdgeInsets.only(top: 4),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: AppColors.accentSoft,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        const Icon(Icons.info_outline_rounded, size: 15, color: AppColors.accent),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
        ),
      ],
    ),
  );
}
