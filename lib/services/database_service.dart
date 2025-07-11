import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._constructor() ;
  static Database? _db ;
  DatabaseService._constructor();

  Future<Database> get database async {
    if (_db != null ) return _db! ;
    _db = await getDatabase() ;
    return _db!;
  }
  Future<Database> getDatabase() async{
    // Get a location using getDatabasesPath
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'demo.db');

    // open the database
    Database database = await openDatabase(
        path,
        version: 2,
        onCreate: _onCreate,
        onUpgrade : (db , oldVersion , newVersion) async {
          if (oldVersion < 2) {
            await _createProduitTable(db) ;
          }
        }
    );
    return database ; 
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createClientTable(db);
    // Ajoute ici d'autres appels : await _createProductTable(db); etc.
  }


  Future<void> _createClientTable(Database db) async {
    await db.execute('''
    CREATE TABLE Client (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nom TEXT NOT NULL,
      surnom TEXT,
      num TEXT
    )
  ''');
  }

  Future<void> _createCompteTable(Database db) async {
    await db.execute('''
    CREATE TABLE Compte (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date_creation TEXT NOT NULL,
      mode_paiement TEXT NOT NULL,
      statut TEXT NOT NULL,
      reste REAL NOT NULL, 
      FOREIGN KEY (client_id) REFERENCES Client(id)
    )
  ''');
  }

  Future<void> _createCommnandeTable(Database db) async {
    await db.execute('''
      CREATE TABLE Commande (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date_livraison TEXT,
        date_paiement TEXT,
        date_commande TEXT NOT NULL,
        total REAL NOT NULL,
        total_paye REAL DEFAULT 0
      )
    ''');
  }

  Future<void> _createDetailTable(Database db) async {
    await db.execute('''
      
    ''');
  }

  Future<void> _createProduitTable(Database db) async {
    await db.execute('''
        CREATE TABLE Produit (
          id INTEGER PRIMARY KEY AUTOINCREMENT , 
          nom_produit TEXT NOT NULL,
          prix_unitaire REAL NOT NULL
        )
    ''');
  }

}