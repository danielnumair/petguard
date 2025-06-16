import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final _dbName = 'petguard.db';
  static final _dbVersion = 1;

  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = join(dir.path, _dbName);
    return await openDatabase(path,
        version: _dbVersion, onCreate: _onCreate, onConfigure: _onConfigure);
  }

  Future<void> _onConfigure(Database db) async {
    // Habilita as constraints de chave estrangeira
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Usuario (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        senha TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE Pet (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        especie TEXT NOT NULL,
        raca TEXT NOT NULL,
        sexo TEXT NOT NULL,
        dataNascimento TEXT,
        observacoes TEXT,
        usuarioId INTEGER NOT NULL,
        FOREIGN KEY (usuarioId) REFERENCES Usuario(id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE Config (
        usuarioId INTEGER PRIMARY KEY,
        lembreteConsulta INTEGER NOT NULL,
        lembreteVacina INTEGER NOT NULL,
        lembreteVermifugo INTEGER NOT NULL,
        diasConsulta INTEGER NOT NULL,
        diasVacina INTEGER NOT NULL,
        diasVermifugo INTEGER NOT NULL,
        FOREIGN KEY (usuarioId) REFERENCES Usuario(id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE Consulta (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        petId INTEGER NOT NULL,
        motivo TEXT NOT NULL,
        veterinario TEXT NOT NULL,
        crmv TEXT NOT NULL,
        peso REAL NOT NULL,
        data TEXT NOT NULL,
        proxima TEXT,
        tratamento TEXT,
        FOREIGN KEY (petId) REFERENCES Pet(id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE Vacina (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        petId INTEGER NOT NULL,
        vacina TEXT NOT NULL,
        veterinario TEXT NOT NULL,
        crmv TEXT NOT NULL,
        peso REAL NOT NULL,
        lote TEXT NOT NULL,
        fabricacao TEXT,
        vencimento TEXT,
        dataAplicacao TEXT NOT NULL,
        proxima TEXT NOT NULL,
        FOREIGN KEY (petId) REFERENCES Pet(id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE Vermifugo (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        petId INTEGER NOT NULL,
        produto TEXT NOT NULL,
        peso REAL NOT NULL,
        dose TEXT NOT NULL,
        data TEXT NOT NULL,
        proxima TEXT,
        FOREIGN KEY (petId) REFERENCES Pet(id) ON DELETE CASCADE
      );
    ''');
  }
}
