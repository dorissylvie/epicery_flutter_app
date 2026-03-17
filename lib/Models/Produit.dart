class Produit {
  final int? id;
  final String nomProduit;
  final double prixUnitaire;
  final double prixPaquet;
  final String photoProduit;
  final int ctgrId;

  Produit({
    this.id,
    required this.nomProduit,
    required this.prixUnitaire,
    required this.prixPaquet,
    required this.photoProduit,
    required this.ctgrId,

  });
  /// Convertir un objet Client en Map (pour SQLite)
  Map<String, Object?> toMap() {
    return {
      'nom_produit': nomProduit,
      'prix_unitaire': prixUnitaire,
      'prix_paquet' : prixPaquet ,
      'photo_produit' : photoProduit ,
      'ctgr_id' : ctgrId
    };
  }
  /// Créer un objet Client depuis un Map (résultat SQLite)
  factory Produit.fromMap(Map<String, Object?> map) {
    return Produit(
      id: map['id'] as int,
      nomProduit: map['nom_produit'] as String,
      prixUnitaire: map['prix_unitaire'] as double,
      prixPaquet : map['prix_paquet'] as double,
      photoProduit : map['photo_produit'] as String,
      ctgrId : map['ctgr_id'] as int
    );
  }
}
