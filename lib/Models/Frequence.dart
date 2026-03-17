class Frequence {
  final int id;
  final String codeFrq;
  final String nomFrq;

  Frequence({
    required this.id,
    required this.codeFrq,
    required this.nomFrq,
  });

  /// Convertir un objet en Map (pour SQLite)
  Map<String, Object?> toMap() {
    return {
      'code_frq' : codeFrq,
      'nom_frq' : nomFrq
    };
  }
  /// Créer un objet depuis un Map (résultat SQLite)
  factory Frequence.fromMap(Map<String, Object?> map) {
    return Frequence(
      id: map['id'] as int,
      codeFrq: map['code_frq'] as String,
      nomFrq: map['nom_frq'] as String
    );
  }
}