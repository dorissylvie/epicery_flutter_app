import "package:sqflite/sqflite.dart";
import 'database_service.dart';

class CompteService {
  final DatabaseService _dbService = DatabaseService.instance;

  Future<int> insertCompte(Map<String, dynamic> data) async {
    final db = await _dbService.database;
    return await db.insert('Compte', data);
  }

  Future<List<Map<String, dynamic>>> getAllComptes() async {
    final db = await _dbService.database;
    return await db.query('Compte');
  }

  Future<List<Map<String, dynamic>>> getAllComptesByIClientId(
      int? clientId) async {
    final db = await _dbService.database;
    return await db
        .query('Compte', where: 'client_id = ?', whereArgs: [clientId]);
  }

  Future<int> updateCompte(int id, Map<String, dynamic> data) async {
    final db = await _dbService.database;
    return await db.update('Compte', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteCompte(int id) async {
    final db = await _dbService.database;
    return await db.delete('Compte', where: 'id = ?', whereArgs: [id]);
  }

  
}
