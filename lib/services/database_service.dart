import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_profile.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'dontsmoke.db');

    return openDatabase(path, version: 1, onCreate: _createDb);
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_profile (
        id INTEGER PRIMARY KEY,
        quitDate TEXT NOT NULL,
        cigarettesPerDay INTEGER NOT NULL,
        costPerPack INTEGER NOT NULL,
        cigarettesPerPack INTEGER NOT NULL
      )
    ''');
  }

  // Получить профиль пользователя
  Future<UserProfile?> getUserProfile() async {
    final db = await database;
    final result = await db.query('user_profile');

    if (result.isEmpty) {
      return null;
    }

    return UserProfile.fromMap(result.first);
  }

  // Создать профиль пользователя
  Future<void> createUserProfile(UserProfile profile) async {
    final db = await database;
    await db.insert('user_profile', profile.toMap());
  }

  // Обновить профиль пользователя
  Future<void> updateUserProfile(UserProfile profile) async {
    final db = await database;
    await db.update(
      'user_profile',
      profile.toMap(),
      where: 'id = ?',
      whereArgs: [profile.id],
    );
  }

  // Удалить профиль (перезагрузка)
  Future<void> deleteUserProfile() async {
    final db = await database;
    await db.delete('user_profile');
  }

  // Очистить базу данных (для отладки)
  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('user_profile');
  }
}
