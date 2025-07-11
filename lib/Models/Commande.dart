class Commande {
  final int id;
  final int clientId;
  final DateTime dateCommande;
  final double montantTotal;

  Commande({
    required this.id,
    required this.clientId,
    required this.dateCommande,
    required this.montantTotal,
  });
}
