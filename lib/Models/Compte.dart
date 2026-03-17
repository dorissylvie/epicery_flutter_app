class Compte {
  final int id;
  final DateTime dateCreation ;
  final String statut ;
  final int clientId;
  final int frqId;


  Compte({
    required this.id,
    required this.dateCreation,
    required this.statut,
    required this.clientId,
    required this.frqId,
  });

  /// Convertir un objet en Map (pour SQLite)
  Map<String, Object?> toMap() {
    return {
      'date_creation' : dateCreation,
      'statut' : statut,
      'client_id' : clientId,
      'frq_id' : frqId
    };
  }
  /// Créer un objet depuis un Map (résultat SQLite)
  factory Compte.fromMap(Map<String, Object?> map) {
    return Compte(
      id: map['id'] as int,
      dateCreation: map['date_creation'] as DateTime,
      statut: map['statut'] as String,
      clientId: map['client_id'] as int,
      frqId: map['frq_id'] as int
    );
  }
}
