class Versement {
  final int id;
  final double montantVerser ;
  final DateTime dateVersement ;
  final String modePaiement ;
  final int compteId ;

  Versement({
    required this.id,
    required this.montantVerser,
    required this.dateVersement,
    required this.modePaiement,
    required this.compteId
  });

  /// Convertir un objet en Map (pour SQLite)
  Map<String, Object?> toMap() {
    return {
      'montant_verser': montantVerser,
      'date_versement': dateVersement,
      'mode_paiement': modePaiement,
      'compte_id': compteId
    };
  }
  /// Créer un objet depuis un Map (résultat SQLite)
  factory Versement.fromMap(Map<String, Object?> map) {
    return Versement(
      id: map['id'] as int,
      montantVerser: map['montant_verser'] as double,
      dateVersement: map['date_versement'] as DateTime,
      modePaiement: map['mode_paiement'] as String,
      compteId: map['compte_id'] as int,
    );
  }
}