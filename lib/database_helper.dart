// File: lib/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// 1. MODEL DATA MOTOR (Diperbarui dengan Harga & GPS)
class Motor {
  int? id;
  String merk;
  String plat;
  String status;
  double lat;
  double lng;
  int hargaHarian;
  int hargaMingguan;
  int hargaBulanan;

  Motor({
    this.id,
    required this.merk,
    required this.plat,
    required this.status,
    required this.lat,
    required this.lng,
    required this.hargaHarian,
    required this.hargaMingguan,
    required this.hargaBulanan,
  });

  // Konversi dari Object ke Map (untuk insert/update ke database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'merk': merk,
      'plat': plat,
      'status': status,
      'lat': lat,
      'lng': lng,
      'hargaHarian': hargaHarian,
      'hargaMingguan': hargaMingguan,
      'hargaBulanan': hargaBulanan,
    };
  }

  // Konversi dari Map ke Object (saat read dari database)
  factory Motor.fromMap(Map<String, dynamic> map) {
    return Motor(
      id: map['id'],
      merk: map['merk'],
      plat: map['plat'],
      status: map['status'],
      lat: map['lat'] ?? -7.7956,
      lng: map['lng'] ?? 110.3695,
      hargaHarian: map['hargaHarian'] ?? 0,
      hargaMingguan: map['hargaMingguan'] ?? 0,
      hargaBulanan: map['hargaBulanan'] ?? 0,
    );
  }
}

// 2. KELAS DATABASE HELPER
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('renttrack.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Jika melakukan perubahan struktur kolom, versi database perlu dinaikkan (misal: version: 2)
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE motor (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        merk TEXT NOT NULL,
        plat TEXT NOT NULL,
        status TEXT NOT NULL,
        lat REAL NOT NULL,
        lng REAL NOT NULL,
        hargaHarian INTEGER NOT NULL,
        hargaMingguan INTEGER NOT NULL,
        hargaBulanan INTEGER NOT NULL
      )
    ''');
  }

  // Menangani migrasi jika tabel lama sudah terlanjur dibuat di HP
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute("ALTER TABLE motor ADD COLUMN lat REAL DEFAULT -7.7956");
      await db.execute(
        "ALTER TABLE motor ADD COLUMN lng REAL DEFAULT 110.3695",
      );
      await db.execute(
        "ALTER TABLE motor ADD COLUMN hargaHarian INTEGER DEFAULT 0",
      );
      await db.execute(
        "ALTER TABLE motor ADD COLUMN hargaMingguan INTEGER DEFAULT 0",
      );
      await db.execute(
        "ALTER TABLE motor ADD COLUMN hargaBulanan INTEGER DEFAULT 0",
      );
    }
  }

  // CREATE (Tambah Motor)
  Future<int> insertMotor(Motor motor) async {
    final db = await instance.database;
    return await db.insert('motor', motor.toMap());
  }

  // READ (Ambil Semua Motor)
  Future<List<Motor>> getAllMotor() async {
    final db = await instance.database;
    final result = await db.query('motor', orderBy: 'id DESC');
    return result.map((json) => Motor.fromMap(json)).toList();
  }

  // UPDATE (Edit Motor)
  Future<int> updateMotor(Motor motor) async {
    final db = await instance.database;
    return await db.update(
      'motor',
      motor.toMap(),
      where: 'id = ?',
      whereArgs: [motor.id],
    );
  }

  // DELETE (Hapus Motor)
  Future<int> deleteMotor(int id) async {
    final db = await instance.database;
    return await db.delete('motor', where: 'id = ?', whereArgs: [id]);
  }
}
