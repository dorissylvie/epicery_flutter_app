import 'package:flutter/material.dart';
import 'package:flutter_app/Models/Client.dart';
import 'package:flutter_app/Models/Compte.dart';
import 'package:flutter_app/pages/clients/ModificationClient.dart';
import 'package:flutter_app/services/client_service.dart';
import 'package:flutter_app/services/compte_service.dart';
import 'package:flutter_app/theme/app_colors.dart';

class AfficheClient extends StatefulWidget {
  final Client clt;
  const AfficheClient({super.key, required this.clt});

  @override
  State<AfficheClient> createState() => _AfficheClientState();
}

class _AfficheClientState extends State<AfficheClient> {
  Client? client;
  List<Compte> comptes = [];
  bool _loadingClient = true;
  bool _loadingComptes = false;

  final ClientService _clientService = ClientService();
  final CompteService _cmptService = CompteService();

  @override
  void initState() {
    super.initState();
    _loadClient();
  }

  Future<void> _loadClient() async {
    setState(() => _loadingClient = true);
    final data = await _clientService.getOneClient(widget.clt.id);
    final loaded = data.map((m) => Client.fromMap(m)).toList();
    setState(() {
      client = loaded[0];
      _loadingClient = false;
    });
    await _loadComptes();
  }

  Future<void> _loadComptes() async {
    setState(() => _loadingComptes = true);
    final data = await _cmptService.getAllComptesByIClientId(client?.id);
    setState(() {
      comptes = data.map((m) => Compte.fromMap(m)).toList();
      _loadingComptes = false;
    });
  }

  Future<void> _creerCompte() async {
    if (client == null) return;
    final int id = await _cmptService.insertCompte({
      'date_creation': DateTime.now().toIso8601String(),
      'statut': 'actif',
      'client_id': client!.id,
      'frq_id': null,
    });
    await _loadComptes();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Compte #$id créé',
            style: const TextStyle(
                color: AppColors.surface, fontWeight: FontWeight.w500)),
        backgroundColor: AppColors.ink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }

  // ── Initiale avatar ──────────────────────────────────────────────────────
  String get _initiale =>
      (client?.nom.isNotEmpty == true) ? client!.nom[0].toUpperCase() : '?';

  @override
  Widget build(BuildContext context) {
    // Loader plein écran pendant le premier chargement
    if (_loadingClient) {
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.ink, strokeWidth: 1.5),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,

      // ── AppBar ────────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: AppColors.ink),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          _AppBarAction(
            icon: Icons.edit_outlined,
            onTap: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => ModificationClient(client: client!)),
              );
              if (result == true) {
                await _loadClient();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Client modifié',
                        style: TextStyle(
                            color: AppColors.surface, fontWeight: FontWeight.w500)),
                    backgroundColor: AppColors.ink,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                );
              }
            },
          ),
          _AppBarAction(icon: Icons.star_outline, onTap: () {}),
          const SizedBox(width: 8),
        ],
      ),

      // ── Body ─────────────────────────────────────────────────────────────
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Hero avatar ───────────────────────────────────────────────
            const SizedBox(height: 20),
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  _initiale,
                  style: const TextStyle(
                    color: AppColors.surface,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Center(
              child: Text(
                client!.surnom,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // ── Fiche infos ───────────────────────────────────────────────
            _Section(
              child: Column(
                children: [
                  _InfoTile(label: 'Nom complet', value: client!.nom),
                  const _TileDivider(),
                  _InfoTile(label: 'Sexe', value: client!.sexe),
                  const _TileDivider(),
                  _InfoTile(label: 'Téléphone', value: client!.num),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Section comptes ───────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    text: 'Comptes ',
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                    children: [
                      TextSpan(
                        text: '(${comptes.length})',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _creerCompte,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.ink,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, color: AppColors.surface, size: 15),
                        SizedBox(width: 5),
                        Text('Nouveau compte',
                            style: TextStyle(
                                color: AppColors.surface,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── Liste des comptes ─────────────────────────────────────────
            if (_loadingComptes)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: CircularProgressIndicator(
                      color: AppColors.ink, strokeWidth: 1.5),
                ),
              )
            else if (comptes.isEmpty)
              _EmptyComptes(onAdd: _creerCompte)
            else
              _Section(
                child: Column(
                  children: [
                    for (int i = 0; i < comptes.length; i++) ...[
                      _CompteRow(compte: comptes[i]),
                      if (i < comptes.length - 1) const _TileDivider(),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Bouton AppBar ─────────────────────────────────────────────────────────────
class _AppBarAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _AppBarAction({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: IconButton(
        icon: Icon(icon, color: AppColors.ink, size: 20),
        onPressed: onTap,
        style: IconButton.styleFrom(
          backgroundColor: AppColors.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}

// ── Conteneur section blanche ─────────────────────────────────────────────────
class _Section extends StatelessWidget {
  final Widget child;
  const _Section({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: child,
    );
  }
}

// ── Ligne info (label + valeur) ───────────────────────────────────────────────
class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.muted, fontSize: 13, fontWeight: FontWeight.w400)),
          Text(value,
              style: const TextStyle(
                  color: AppColors.ink, fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ── Séparateur interne ────────────────────────────────────────────────────────
class _TileDivider extends StatelessWidget {
  const _TileDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
        color: AppColors.divider, height: 1, indent: 16, endIndent: 16);
  }
}

// ── Ligne compte ──────────────────────────────────────────────────────────────
class _CompteRow extends StatelessWidget {
  final Compte compte;
  const _CompteRow({required this.compte});

  @override
  Widget build(BuildContext context) {
    // Couleur badge statut
    final bool isActif = (compte.statut?.toLowerCase() ?? 'actif') == 'actif';
    final Color badgeBg =
      isActif ? AppColors.successSoft : AppColors.dangerSoft;
    final Color badgeFg =
      isActif ? AppColors.success : AppColors.danger;

    // Date formatée
    String dateStr = '—';
    if (compte.dateCreation != null) {
      final d = compte.dateCreation!;
      dateStr =
          '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Icône
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(Icons.account_balance_wallet_outlined,
                size: 18, color: AppColors.muted),
          ),
          const SizedBox(width: 14),

          // ID + date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Compte #${compte.id}',
                    style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('Créé le $dateStr',
                    style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w400)),
              ],
            ),
          ),

          // Badge statut
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              isActif ? 'Actif' : 'Inactif',
              style: TextStyle(
                  color: badgeFg, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ── État vide comptes ─────────────────────────────────────────────────────────
class _EmptyComptes extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyComptes({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          const Icon(Icons.account_balance_wallet_outlined,
              color: AppColors.muted, size: 28),
          const SizedBox(height: 10),
          const Text('Aucun compte',
              style: TextStyle(
                  color: AppColors.ink, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text('Ce client n\'a pas encore de compte.',
              style: TextStyle(color: AppColors.muted, fontSize: 12)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.ink,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Créer un compte',
                  style: TextStyle(
                      color: AppColors.surface,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
