import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'seed_data.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('badelha.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (Platform.isWindows || Platform.isLinux) {
      // Initialize sqflite_common_ffi for desktop platforms
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String path;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final appDocDir = await getApplicationDocumentsDirectory();
      path = join(appDocDir.path, 'BadelhaApp', filePath);
      // Ensure folder exists
      final dir = Directory(dirname(path));
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
    } else {
      final dbPath = await getDatabasesPath();
      path = join(dbPath, filePath);
    }

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onOpen: (db) async {
        try {
          await db.execute('ALTER TABLE users ADD COLUMN email TEXT;');
        } catch (_) {}
        try {
          await db.execute("ALTER TABLE users ADD COLUMN role TEXT DEFAULT 'customer';");
        } catch (_) {}
        try {
          await db.execute("ALTER TABLE users ADD COLUMN status TEXT DEFAULT 'active';");
        } catch (_) {}
        try {
          await db.execute('ALTER TABLE users ADD COLUMN updated_at TEXT;');
        } catch (_) {}
        try {
          await db.execute('ALTER TABLE items ADD COLUMN updated_at TEXT;');
        } catch (_) {}
        try {
          await db.execute('ALTER TABLE items ADD COLUMN expires_at TEXT;');
        } catch (_) {}
        try {
          await db.execute('ALTER TABLE items ADD COLUMN last_refresh_at TEXT;');
        } catch (_) {}
        try {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS swap_history_log (
              id TEXT PRIMARY KEY,
              swap_offer_id TEXT NOT NULL,
              sender_id TEXT NOT NULL,
              receiver_id TEXT NOT NULL,
              offered_item_id TEXT NOT NULL,
              requested_item_id TEXT NOT NULL,
              completed_at TEXT NOT NULL,
              final_status TEXT NOT NULL,
              notes TEXT
            );
          ''');
        } catch (_) {}
        await SeedData.populateIfEmpty(db);
      },
    );
  }

  Future<void> clearAllMarketData() async {
    final db = await database;
    await SeedData.clearAllUserAndMarketData(db);
    await SeedData.populateIfEmpty(db);
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Users Table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        image TEXT,
        email TEXT,
        city TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'customer',
        status TEXT NOT NULL DEFAULT 'active',
        created_at TEXT NOT NULL,
        updated_at TEXT,
        rating REAL DEFAULT 5.0,
        trust_score INTEGER DEFAULT 80,
        is_verified INTEGER DEFAULT 0,
        swaps_completed INTEGER DEFAULT 0
      )
    ''');

    // 2. Stores Table
    await db.execute('''
      CREATE TABLE stores (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        store_name TEXT NOT NULL,
        logo TEXT,
        bio TEXT,
        city TEXT NOT NULL,
        phone TEXT NOT NULL,
        is_verified INTEGER DEFAULT 1,
        rating REAL DEFAULT 5.0,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // 3. Categories Table
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        parent_id TEXT,
        icon TEXT NOT NULL,
        FOREIGN KEY (parent_id) REFERENCES categories(id) ON DELETE CASCADE
      )
    ''');

    // 4. Items Table
    await db.execute('''
      CREATE TABLE items (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        category_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        brand TEXT,
        model TEXT,
        condition TEXT NOT NULL,
        quality TEXT NOT NULL,
        quantity INTEGER DEFAULT 1,
        estimated_value REAL NOT NULL,
        city TEXT NOT NULL,
        phone_number TEXT NOT NULL,
        wanted_description TEXT,
        wanted_category_id TEXT,
        swap_type TEXT NOT NULL,
        status TEXT NOT NULL,
        is_featured INTEGER DEFAULT 0,
        views_count INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        expires_at TEXT,
        last_refresh_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (category_id) REFERENCES categories(id)
      )
    ''');

    // 5. Item Images Table
    await db.execute('''
      CREATE TABLE item_images (
        id TEXT PRIMARY KEY,
        item_id TEXT NOT NULL,
        image_path TEXT NOT NULL,
        is_primary INTEGER DEFAULT 0,
        FOREIGN KEY (item_id) REFERENCES items(id) ON DELETE CASCADE
      )
    ''');

    // 6. Wanted Items Table
    await db.execute('''
      CREATE TABLE wanted_items (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        category_id TEXT,
        brand TEXT,
        model TEXT,
        min_value REAL,
        max_value REAL,
        target_city TEXT,
        notes TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // 7. Swap Offers Table
    await db.execute('''
      CREATE TABLE swap_offers (
        id TEXT PRIMARY KEY,
        sender_id TEXT NOT NULL,
        receiver_id TEXT NOT NULL,
        offered_item_id TEXT NOT NULL,
        requested_item_id TEXT NOT NULL,
        cash_difference REAL DEFAULT 0.0,
        cash_payer TEXT,
        message TEXT,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (sender_id) REFERENCES users(id),
        FOREIGN KEY (receiver_id) REFERENCES users(id),
        FOREIGN KEY (offered_item_id) REFERENCES items(id),
        FOREIGN KEY (requested_item_id) REFERENCES items(id)
      )
    ''');

    // 8. Ratings Table
    await db.execute('''
      CREATE TABLE ratings (
        id TEXT PRIMARY KEY,
        swap_id TEXT NOT NULL,
        reviewer_id TEXT NOT NULL,
        reviewed_id TEXT NOT NULL,
        stars REAL NOT NULL,
        comment TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (reviewer_id) REFERENCES users(id),
        FOREIGN KEY (reviewed_id) REFERENCES users(id)
      )
    ''');

    // 9. Favorites Table
    await db.execute('''
      CREATE TABLE favorites (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        item_id TEXT NOT NULL,
        created_at TEXT NOT NULL,
        UNIQUE(user_id, item_id),
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (item_id) REFERENCES items(id) ON DELETE CASCADE
      )
    ''');

    // 10. Notifications Table
    await db.execute('''
      CREATE TABLE notifications (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        type TEXT NOT NULL,
        payload TEXT,
        is_read INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // 11. Reports Table
    await db.execute('''
      CREATE TABLE reports (
        id TEXT PRIMARY KEY,
        reporter_id TEXT NOT NULL,
        reported_item_id TEXT,
        reported_user_id TEXT,
        reason TEXT NOT NULL,
        details TEXT,
        status TEXT DEFAULT 'pending',
        created_at TEXT NOT NULL
      )
    ''');

    // 12. Swap History Audit Log Table
    await db.execute('''
      CREATE TABLE swap_history_log (
        id TEXT PRIMARY KEY,
        swap_offer_id TEXT NOT NULL,
        sender_id TEXT NOT NULL,
        receiver_id TEXT NOT NULL,
        offered_item_id TEXT NOT NULL,
        requested_item_id TEXT NOT NULL,
        completed_at TEXT NOT NULL,
        final_status TEXT NOT NULL,
        notes TEXT
      )
    ''');

    // Indexes for high performance
    await db.execute('CREATE INDEX idx_items_category ON items(category_id);');
    await db.execute('CREATE INDEX idx_items_city ON items(city);');
    await db.execute('CREATE INDEX idx_items_status ON items(status);');
    await db.execute('CREATE INDEX idx_items_user ON items(user_id);');
    await db.execute('CREATE INDEX idx_items_featured ON items(is_featured);');
    await db.execute('CREATE INDEX idx_offers_receiver ON swap_offers(receiver_id);');
    await db.execute('CREATE INDEX idx_offers_sender ON swap_offers(sender_id);');
    await db.execute('CREATE INDEX idx_notifications_user ON notifications(user_id, is_read);');
    await db.execute('CREATE INDEX idx_swap_history_users ON swap_history_log(sender_id, receiver_id);');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
