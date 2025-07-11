import "package:sqflite/sqflite.dart" ;
import 'database_service.dart';

class ProduitService {
  final DatabaseService _dbService = DatabaseService.instance;

  Future<int> insertProduit(Map<String, dynamic> data) async {
    final db = await _dbService.database;
    return await db.insert('Produit', data);
  }

  Future<List<Map<String, dynamic>>> getAllProduits() async {
    final db = await _dbService.database;
    return await db.query('Produit');
  }

  Future<int> updateProduit(int id, Map<String, dynamic> data) async {
    final db = await _dbService.database;
    return await db.update('Produit', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteProduit(int id) async {
    final db = await _dbService.database;
    return await db.delete('Produit', where: 'id = ?', whereArgs: [id]);
  }
}
