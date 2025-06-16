import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import '../models/consulta.dart';

class ConsultaDAO {
  final table = 'Consulta';

  Future<int> insert(Consulta consulta) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert(table, consulta.toMap());
  }

  Future<List<Consulta>> getByPet(int petId) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(table, where: 'petId = ?', whereArgs: [petId]);
    return result.map((e) => Consulta.fromMap(e)).toList();
  }

  Future<int> update(Consulta consulta) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update(table, consulta.toMap(), where: 'id = ?', whereArgs: [consulta.id]);
  }

  Future<int> delete(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Consulta>> getByUsuario(int usuarioId) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery('''
    SELECT c.* 
    FROM Consulta c
    INNER JOIN Pet p ON c.petId = p.id
    WHERE p.usuarioId = ?
  ''', [usuarioId]);

    return result.map((e) => Consulta.fromMap(e)).toList();
  }
}