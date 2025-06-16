import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import '../models/vermifugo.dart';

class VermifugoDAO {
  final table = 'Vermifugo';

  Future<int> insert(Vermifugo vermifugo) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert(table, vermifugo.toMap());
  }

  Future<List<Vermifugo>> getByPet(int petId) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(table, where: 'petId = ?', whereArgs: [petId]);
    return result.map((e) => Vermifugo.fromMap(e)).toList();
  }

  Future<int> update(Vermifugo vermifugo) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update(table, vermifugo.toMap(), where: 'id = ?', whereArgs: [vermifugo.id]);
  }

  Future<int> delete(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Vermifugo>> getByUsuario(int usuarioId) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery('''
    SELECT v.*
    FROM vermifugo v
    INNER JOIN pet p ON v.petId = p.id
    WHERE p.usuarioId = ?
  ''', [usuarioId]);

    return result.map((e) => Vermifugo.fromMap(e)).toList();
  }
}