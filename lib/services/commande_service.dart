import "package:sqflite/sqflite.dart" ;
import 'database_service.dart';

class CommandeService {
  final DatabaseService _dbService = DatabaseService.instance;

  Future<int> insertCommande(Map<String, dynamic> data) async {
    final db = await _dbService.database;
    return await db.insert('Commande', data);
  }

  Future<List<Map<String, dynamic>>> getAllCommandes() async {
    final db = await _dbService.database;
    return await db.query('Commande');
  }

  Future<int> updateCommande(int id, Map<String, dynamic> data) async {
    final db = await _dbService.database;
    return await db.update('Commande', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteCommande(int id) async {
    final db = await _dbService.database;
    return await db.delete('Commande', where: 'id = ?', whereArgs: [id]);
  }

   Future<List<Map<String, Object?>>> getOneCommande(int? id) async {
    final db = await _dbService.database;
    return await db.query('Commande', where: 'id = ?', whereArgs: [id]);
  }
}