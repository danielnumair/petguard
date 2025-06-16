import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/usuario.dart';

class UsuarioDAO {
  final table = 'Usuario';

  Future<int> insert(Usuario usuario) async {
    final db = await DatabaseHelper.instance.database;
    try {
      return await db.insert(table, usuario.toMap());
    } catch (e) {
      print('Erro ao inserir usuário: $e');
      return -1; // Indica falha
    }
  }

  Future<Usuario?> getByEmail(String email) async {
    final db = await DatabaseHelper.instance.database;
    try {
      final maps = await db.query(table, where: 'email = ?', whereArgs: [email]);
      if (maps.isNotEmpty) {
        return Usuario.fromMap(maps.first);
      }
    } catch (e) {
      print('Erro ao buscar usuário por e-mail: $e');
    }
    return null;
  }

  Future<List<Usuario>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    try {
      final result = await db.query(table);
      return result.map((e) => Usuario.fromMap(e)).toList();
    } catch (e) {
      print('Erro ao buscar todos os usuários: $e');
      return [];
    }
  }

  Future<int> update(Usuario usuario) async {
    final db = await DatabaseHelper.instance.database;
    try {
      return await db.update(table, usuario.toMap(), where: 'id = ?', whereArgs: [usuario.id]);
    } catch (e) {
      print('Erro ao atualizar usuário: $e');
      return -1;
    }
  }

  Future<int> delete(int id) async {
    final db = await DatabaseHelper.instance.database;
    try {
      return await db.delete(table, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print('Erro ao deletar usuário: $e');
      return -1;
    }
  }

  Future<Usuario?> login(String login, String senha) async {
    final db = await DatabaseHelper.instance.database;
    try {
      final result = await db.query(
        table,
        where: '(nome = ? OR email = ?) AND senha = ?',
        whereArgs: [login, login, senha],
      );
      if (result.isNotEmpty) {
        return Usuario.fromMap(result.first);
      }
    } catch (e) {
      print('Erro no login do usuário: $e');
    }
    return null;
  }

  Future<bool> emailExiste(String email) async {
    final db = await DatabaseHelper.instance.database;
    try {
      final result = await db.query(table, where: 'email = ?', whereArgs: [email]);
      return result.isNotEmpty;
    } catch (e) {
      print('Erro ao verificar existência de e-mail: $e');
      return false;
    }
  }

  Future<Usuario?> getByLogin(String login) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'usuario',
      where: 'login = ?',
      whereArgs: [login],
    );

    if (result.isNotEmpty) {
      return Usuario.fromMap(result.first);
    }

    return null;
  }
}
