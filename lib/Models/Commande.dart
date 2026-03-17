class Commande {
  final int id;
  final DateTime dateCommande;
  final String typePaiement ;
  final double totalAPayer;
  final double resteAPayer;
  final int compteId ;

  Commande({
    required this.id,
    required this.dateCommande,
    required this.typePaiement,
    required this.totalAPayer,
    required this.resteAPayer,
    required this.compteId,

  });

  /// Convertir un objet en Map (pour SQLite)
  Map<String, Object?> toMap() {
    return {
      'date_commande' : dateCommande ,
      'type_paiement' : typePaiement ,
      'total_a_payer' : totalAPayer ,
      'reste_a_payer' : resteAPayer,
      'compte_id' : compteId
    };
  }
  /// Créer un objet depuis un Map (résultat SQLite)
  factory Commande.fromMap(Map<String, Object?> map) {
    return Commande(
      id: map['id'] as int,
      dateCommande : map['date_commande'] as DateTime,
      typePaiement : map['type_paiement'] as String,
      totalAPayer: map['total_a_payer']  as double,
      resteAPayer: map['reste_a_payer'] as double,
      compteId: map['compte_id'] as int
    );
  }
}
