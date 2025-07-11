class Client {
  final int? id;
  final String nom;
  final String surnom;
  final String num;

  Client({
    this.id,
    required this.nom,
    required this.surnom,
    required this.num
  });

  /// Convertir un objet Client en Map (pour SQLite)
  Map<String, Object?> toMap() {
    return {
      'nom': nom,
      'surnom': surnom,
      'num': num,
    };
  }
  /// Créer un objet Client depuis un Map (résultat SQLite)
  factory Client.fromMap(Map<String, Object?> map) {
    return Client(
      id: map['id'] as int,
      nom: map['nom'] as String,
      surnom: map['surnom'] as String,
      num: map['num'] as String,
    );
  }
}
