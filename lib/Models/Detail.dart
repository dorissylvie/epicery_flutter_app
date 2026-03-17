class Detail {
  final int id;
  final double quantite;
  final double prixReel;
  final String unite ;
  final int commandeId;
  final int produitId;

Detail({
    required this.id,
    required this.quantite,
    required this.prixReel,
    required this.unite,
    required this.commandeId,
    required this.produitId,
  });

  /// Convertir un objet en Map (pour SQLite)
  Map<String, Object?> toMap() {
    return {
      'quantite' : quantite,
      'prix_reel' : prixReel,
      'unite' : unite,
      'commande_id' : commandeId,
      'produit_id' : produitId
    };
  }
  /// Créer un objet depuis un Map (résultat SQLite)
  factory Detail.fromMap(Map<String, Object?> map) {
    return Detail(
      id: map['id'] as int,
      quantite: map['quantite'] as double,
      prixReel: map['prix_reel'] as double,
      unite: map['unite'] as String,
      commandeId: map['commande_id'] as int,
      produitId: map['produit_id'] as int
    );
  }
}
