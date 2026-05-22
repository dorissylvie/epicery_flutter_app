import 'package:flutter/material.dart';
import 'package:flutter_app/Models/Commande.dart';
import 'package:flutter_app/services/commande_service.dart';
import 'package:flutter_app/pages/commandes/AjoutCommande.dart';
import 'package:flutter_app/pages/commandes/AfficheCommande.dart';
import 'package:flutter_app/theme/app_colors.dart';

class CommandePage extends StatefulWidget {
  const CommandePage({super.key});

  @override
  State<CommandePage> createState() => _CommandePageState();
}

class _CommandePageState extends State<CommandePage> {
  List<Commande> commandes = [];
  bool _loading = true;
  final CommandeService _commandeService = CommandeService();

  @override
  void initState() {
    super.initState();
    _loadCommandes();
  }

  Future<void> _loadCommandes() async {
    setState(() => _loading = true);
    final data = await _commandeService.getAllCommandes();
    final List<Commande> loaded =
        data.map((map) => Commande.fromMap(map)).toList();
    setState(() {
      commandes = loaded;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      // ── AppBar ──────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 24,
        title: const Text(
          'Commandes',
          style: TextStyle(
            color: AppColors.ink,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.4,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined,
                  color: AppColors.ink, size: 22),
              onPressed: () {},
              style: IconButton.styleFrom(
                backgroundColor: AppColors.surface,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),

      // ── Body ────────────────────────────────────────────────────────────
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.ink,
                strokeWidth: 1.5,
              ),
            )
          : commandes.isEmpty
              ? _EmptyState(onRefresh: _loadCommandes)
              : RefreshIndicator(
                  color: AppColors.ink,
                  onRefresh: _loadCommandes,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                    itemCount: commandes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final commande = commandes[index];
                      return _CommandeCard(
                        commande: commande,
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AfficheCommande(cmd: commande),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

      // ── FAB ─────────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AjoutCommande()),
          );
          if (result == true) {
            await _loadCommandes();
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'Commande ajoutée',
                  style: TextStyle(
                      color: AppColors.surface, fontWeight: FontWeight.w500),
                ),
                backgroundColor: AppColors.ink,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            );
          }
        },
        child: const Icon(Icons.add, size: 22),
      ),
    );
  }
}

// ── Carte commande ───────────────────────────────────────────────────────────
class _CommandeCard extends StatelessWidget {
  final Commande commande;
  final VoidCallback onTap;

  const _CommandeCard({required this.commande, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final date = commande.dateCommande.toLocal();
    final dateStr =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── En-tête : ID + date ───────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#${commande.id}',
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  dateStr,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: 12),

            // ── Infos principales ────────────────────────────────────────
            _InfoRow(
              label: 'Paiement',
              value: commande.typePaiement,
            ),
            const SizedBox(height: 6),
            _InfoRow(
              label: 'Compte',
              value: '${commande.compteId}',
            ),

            const SizedBox(height: 12),

            // ── Montants ─────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _AmountChip(
                    label: 'Total',
                    amount: commande.totalAPayer,
                    subtle: false,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _AmountChip(
                    label: 'Reste',
                    amount: commande.resteAPayer,
                    subtle: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Ligne label / valeur ─────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.muted,
                fontSize: 12,
                fontWeight: FontWeight.w400)),
        Text(value,
            style: const TextStyle(
                color: AppColors.ink, fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

// ── Chip montant ─────────────────────────────────────────────────────────────
class _AmountChip extends StatelessWidget {
  final String label;
  final num amount;
  final bool subtle;

  const _AmountChip(
      {required this.label, required this.amount, required this.subtle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: subtle ? AppColors.bg : AppColors.ink,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: subtle ? AppColors.muted : AppColors.onAccentMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.4)),
          const SizedBox(height: 2),
          Text('$amount Ar',
              style: TextStyle(
                  color: subtle ? AppColors.ink : AppColors.surface,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2)),
        ],
      ),
    );
  }
}

// ── État vide ────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final VoidCallback onRefresh;

  const _EmptyState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: const Icon(Icons.receipt_long_outlined,
                color: AppColors.muted, size: 28),
          ),
          const SizedBox(height: 16),
          const Text('Aucune commande',
              style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          const Text('Appuyez sur + pour en ajouter une.',
              style: TextStyle(color: AppColors.muted, fontSize: 13)),
          const SizedBox(height: 20),
          TextButton(
            onPressed: onRefresh,
            child: const Text('Actualiser',
                style:
                    TextStyle(color: AppColors.ink, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
