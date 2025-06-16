import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/pet.dart';

class PetDAO {
  final table = 'Pet';

  Future<int> insert(Pet pet) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert(table, pet.toMap());
  }

  Future<List<Pet>> getByUsuario(int usuarioId) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(table, where: 'usuarioId = ?', whereArgs: [usuarioId]);
    return result.map((e) => Pet.fromMap(e)).toList();
  }

  Future<int> update(Pet pet) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update(table, pet.toMap(), where: 'id = ?', whereArgs: [pet.id]);
  }

  Future<int> delete(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }
}