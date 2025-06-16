import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/vacina.dart';

class VacinaDAO {
  final table = 'Vacina';

  Future<int> insert(Vacina vacina) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert(table, vacina.toMap());
  }

  Future<List<Vacina>> getByPet(int petId) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(table, where: 'petId = ?', whereArgs: [petId]);
    return result.map((e) => Vacina.fromMap(e)).toList();
  }

  Future<int> update(Vacina vacina) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update(table, vacina.toMap(), where: 'id = ?', whereArgs: [vacina.id]);
  }

  Future<int> delete(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Vacina>> getByUsuario(int usuarioId) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery('''
    SELECT v.*
    FROM vacina v
    INNER JOIN pet p ON v.petId = p.id
    WHERE p.usuarioId = ?
  ''', [usuarioId]);

    return result.map((e) => Vacina.fromMap(e)).toList();
  }
}