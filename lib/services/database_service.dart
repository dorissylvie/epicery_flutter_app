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
        version: 4,
        onCreate: _onCreate,
        onUpgrade : (db , oldVersion , newVersion) async {
          if (oldVersion < 4) {
            await  _onCreate(db , 4 ) ;
          }
        }
    );
    return database ; 
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createClientTable(db);
    await _createFrequenceTable(db);
    await _createCompteTable(db) ;
    await _createVersementTable(db);
    await _createCommandeTable(db) ;
    await _createCategorieTable(db);
    await _createProduitTable(db) ;
    await _createDetailTable(db) ;

    // Ajoute ici d'autres appels : await _createProductTable(db); etc.
  }


  Future<void> _createClientTable(Database db) async {
    await db.execute('''
    CREATE TABLE Client (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nom TEXT NOT NULL,
      surnom TEXT,
      num TEXT NOT NULL, 
      sexe TEXT NOT NULL,
      adresse TEXT,
      photo TEXT
    )
  ''');
  }

  Future<void> _createFrequenceTable(Database db) async {
    await db.execute('''
     CREATE TABLE Frequence (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code_frq TEXT,
        nom_frq TEXT
      )
    ''') ;
  }

  Future<void> _createCompteTable(Database db) async {
    await db.execute('''
    CREATE TABLE Compte (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date_creation TEXT NOT NULL,
      statut TEXT NOT NULL,
      client_id INTEGER,
      frq_id INTEGER,
      FOREIGN KEY (client_id) REFERENCES Client(id),
      FOREIGN KEY (frq_id) REFERENCES Frequence(id)
    )
  ''');
  }

  Future<void> _createVersementTable(Database db) async {
    await db.execute('''
      CREATE TABLE Versement (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        montant_verser  REAL DEFAULT 0 ,
        date_versement TEXT NOT NULL ,  
        mode_paiement TEXT,
        compte_id INTEGER,
        FOREIGN KEY (compte_id) REFERENCES Compte(id)
      )
    ''');
  }

  Future<void> _createCommandeTable(Database db) async {
    await db.execute('''
      CREATE TABLE Commande (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date_commande TEXT NOT NULL,
        type_paiement TEXT NOT NULL DEFAULT 'complet' CHECK(type_paiement IN ('complet', 'partiel', 'credit')),
        total_a_payer REAL NOT NULL,
        reste_a_payer REAL DEFAULT 0 , 
        compte_id INTEGER,
        FOREIGN KEY (compte_id) REFERENCES Compte(id)
      )
    ''');
  }

  Future<void> _createCategorieTable(Database db) async {
    await db.execute('''
      CREATE TABLE Categorie (
           id INTEGER PRIMARY KEY AUTOINCREMENT , 
           code_ctgr TEXT,
           nom_ctgr TEXT 
      ) 
    ''');
  }

  Future<void> _createProduitTable(Database db) async {
    await db.execute('''
      CREATE TABLE Produit (
        id INTEGER PRIMARY KEY AUTOINCREMENT , 
        nom_produit TEXT NOT NULL,
        prix_unitaire REAL NOT NULL,
        prix_paquet REAL,
        photo_produit TEXT ,  
        ctgr_id INTEGER,
        FOREIGN KEY (ctgr_id) REFERENCES Categorie(id)
      )
    ''');
  }

  Future<void> _createDetailTable(Database db) async {
    await db.execute('''
      CREATE TABLE Detail (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        quantite REAL ,
        unite TEXT , 
        prix_reel REAL  ,
        commande_id INTEGER,
        produit_id INTEGER, 
        FOREIGN KEY (produit_id) REFERENCES Produit(id),
        FOREIGN KEY (commande_id) REFERENCES Commande(id)
       )
    ''');
  }
}