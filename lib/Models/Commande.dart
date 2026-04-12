class Commande {
  final int? id;
  final DateTime dateCommande;
  final String typePaiement;
  final double totalAPayer;
  final double resteAPayer;
  final int? compteId;

  Commande({
    this.id,
    required this.dateCommande,
    required this.typePaiement,
    required this.totalAPayer,
    required this.resteAPayer,
    required this.compteId,
  });

  /// Convertir un objet en Map (pour SQLite)
  Map<String, Object?> toMap() {
    return {
      'date_commande': dateCommande.toIso8601String(),
      'type_paiement': typePaiement,
      'total_a_payer': totalAPayer,
      'reste_a_payer': resteAPayer,
      'compte_id': compteId
    };
  }

  /// Créer un objet depuis un Map (résultat SQLite)
  factory Commande.fromMap(Map<String, Object?> map) {
    return Commande(
        id: map['id'] as int,
        dateCommande: DateTime.parse(map['date_commande'] as String),
        typePaiement: map['type_paiement'] as String,
        totalAPayer: (map['total_a_payer'] as num).toDouble(),
        resteAPayer: (map['reste_a_payer'] as num).toDouble(),
        compteId: map['compte_id'] as int?);
  }
}
