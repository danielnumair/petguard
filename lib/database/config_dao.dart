import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import '../models/config.dart';

class ConfigDAO {
  final table = 'Config';

  Future<int> insert(Config config) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert(table, config.toMap());
  }

  Future<Config?> getByUsuario(int usuarioId) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(table, where: 'usuarioId = ?', whereArgs: [usuarioId]);
    if (result.isNotEmpty) {
      return Config.fromMap(result.first);
    }
    return null;
  }

  Future<int> update(Config config) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update(table, config.toMap(), where: 'usuarioId = ?', whereArgs: [config.usuarioId]);
  }

  Future<int> delete(int usuarioId) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete(table, where: 'usuarioId = ?', whereArgs: [usuarioId]);
  }

  Future<void> salvar(Config config) async {
    final existente = await getByUsuario(config.usuarioId);
    if (existente == null) {
      await insert(config);
    } else {
      await update(config);
    }
  }
}
