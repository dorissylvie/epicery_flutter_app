import "package:sqflite/sqflite.dart";
import 'database_service.dart';

class DetailService {
  final DatabaseService _dbService = DatabaseService.instance;

  Future<int> insertDetail(Map<String, dynamic> data) async {
    final db = await _dbService.database;
    return await db.insert('Detail', data);
  }

  Future<List<Map<String, dynamic>>> getAllDetails() async {
    final db = await _dbService.database;
    return await db.query('Detail');
  }

  Future<List<Map<String, dynamic>>> getAllDetailsByCommandeId(int id) async {
    final db = await _dbService.database;
    final results =  await db.query('Detail', where: 'commande_id = ?', whereArgs: [id]);

    return results; // Retourne la liste des détails
  }

  Future<int> updateDetail(int id, Map<String, dynamic> data) async {
    final db = await _dbService.database;
    return await db.update('Detail', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteDetail(int id) async {
    final db = await _dbService.database;
    return await db.delete('Detail', where: 'id = ?', whereArgs: [id]);
  }
}
