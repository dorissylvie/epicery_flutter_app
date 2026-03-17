class Categorie {
  final int id;
  final String codeCtgr;
  final String nomCtgr;

  Categorie({
    required this.id,
    required this.codeCtgr,
    required this.nomCtgr,
  });

  /// Convertir un objet en Map (pour SQLite)
  Map<String, Object?> toMap() {
    return {
      'code_ctgr' : codeCtgr ,
      'nom_ctgr' : nomCtgr
    };
  }
  /// Créer un objet depuis un Map (résultat SQLite)
  factory Categorie.fromMap(Map<String, Object?> map) {
    return Categorie(
      id: map['id'] as int,
      codeCtgr : map['code_ctgr'] as String ,
      nomCtgr: map['nom_ctgr'] as String
    );
  }
}