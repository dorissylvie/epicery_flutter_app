import 'package:flutter/material.dart';
import 'package:flutter_app/Models/Produit.dart';
import 'package:flutter_app/pages/produits/ModificationProduit.dart';
import 'package:flutter_app/services/produit_service.dart';
import 'package:flutter_app/theme/app_colors.dart';

class AfficheProduit extends StatefulWidget {
  final Produit prd;
  const AfficheProduit({super.key, required this.prd});

  @override
  State<AfficheProduit> createState() => _AfficheProduitState();
}

class _AfficheProduitState extends State<AfficheProduit> {
  Produit? produit;
  bool _loading = true;
  final ProduitService _produitService = ProduitService();

  @override
  void initState() {
    super.initState();
    _loadProduit();
  }

  Future<void> _loadProduit() async {
    setState(() => _loading = true);
    final data = await _produitService.getOneProduit(widget.prd.id);
    final loaded = data.map((m) => Produit.fromMap(m)).toList();
    setState(() {
      produit = loaded[0];
      _loading = false;
    });
  }

  String get _initiale => (produit?.nomProduit.isNotEmpty == true)
      ? produit!.nomProduit[0].toUpperCase()
      : '?';

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.ink, strokeWidth: 1.5),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,

      // ── AppBar ─────────────────────────────────────────────────────────
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
                    builder: (_) => ModificationProduit(produit: produit!)),
              );
              if (result == true) {
                await _loadProduit();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Produit modifié',
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

      // ── Body ───────────────────────────────────────────────────────────
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Hero produit ────────────────────────────────────────────
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
                produit!.nomProduit,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ── Prix — deux chips côte à côte ───────────────────────────
            Row(
              children: [
                Expanded(
                  child: _PrixChip(
                    label: 'Prix unitaire',
                    value: '${produit!.prixUnitaire} DH',
                    dark: true,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _PrixChip(
                    label: 'Prix paquet',
                    value: '${produit!.prixPaquet} DH',
                    dark: false,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Fiche détails ───────────────────────────────────────────
            _Section(
              child: Column(
                children: [
                  _InfoTile(
                    icon: Icons.category_outlined,
                    label: 'Catégorie',
                    value: produit!.ctgrId.toString(),
                  ),
                  // Ajoute d'autres champs ici si ton modèle en a davantage
                  // ex: const _TileDivider(),
                  // _InfoTile(icon: Icons.inventory_2_outlined, label: 'Stock', value: '…'),
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

// ── Chip prix ─────────────────────────────────────────────────────────────────
class _PrixChip extends StatelessWidget {
  final String label;
  final String value;
  final bool dark;

  const _PrixChip(
      {required this.label, required this.value, required this.dark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: dark ? AppColors.ink : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: dark ? null : Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: dark ? AppColors.onAccentMuted : AppColors.muted,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: dark ? AppColors.surface : AppColors.ink,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section blanche ───────────────────────────────────────────────────────────
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

// ── Ligne info avec icône ─────────────────────────────────────────────────────
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 17, color: AppColors.muted),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w400)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
