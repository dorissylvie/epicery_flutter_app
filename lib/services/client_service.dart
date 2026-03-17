import "package:sqflite/sqflite.dart" ;
import 'database_service.dart';
import 'package:flutter_app/Models/Client.dart' ;

class ClientService {
  final DatabaseService _dbService = DatabaseService.instance;

  Future<int> insertClient(Map<String, Object?> data) async {
    final db = await _dbService.database;
    return await db.insert('Client', data);
  }

  Future<List<Map<String, dynamic>>> getAllClients() async {
    final db = await _dbService.database;
    return await db.query('Client');
  }

  Future<List<Map<String, Object?>>> getOneClient(int? id) async {
    final db = await _dbService.database;
    return await db.query('Client' ,where: 'id = ?' , whereArgs:[id] );
  }

  Future<int> updateClient(int? id, Map<String, dynamic> data) async {
    final db = await _dbService.database;
    return await db.update('Client', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteClient(int id) async {
    final db = await _dbService.database;
    return await db.delete('Client', where: 'id = ?', whereArgs: [id]);
  }

}
