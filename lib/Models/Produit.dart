import 'dart:ffi';

class Produit {
  final int? id;
  final String nom_produit;
  final double prix_unitaire;

  Produit({
    this.id,
    required this.nom_produit,
    required this.prix_unitaire,
  });
  /// Convertir un objet Client en Map (pour SQLite)
  Map<String, Object?> toMap() {
    return {
      'nom_produit': nom_produit,
      'prix_unitaire': prix_unitaire,
    };
  }
  /// Créer un objet Client depuis un Map (résultat SQLite)
  factory Produit.fromMap(Map<String, Object?> map) {
    return Produit(
      id: map['id'] as int,
      nom_produit: map['nom_produit'] as String,
      prix_unitaire: map['prix_unitaire'] as double,
    );
  }
}
