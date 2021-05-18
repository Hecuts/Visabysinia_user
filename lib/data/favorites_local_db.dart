

import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tourist_guide/data/favorite_datasrc_interface.dart';
import 'package:tourist_guide/models/favorite.dart';

class FavoritesLocalDb extends IFavoritesDataSource{
  //todo
  static late String path;
  static final _databaseName = "favorites.db";
  static final _databaseVersion = 1;
  static final _favoritesTable = "favorites";

  FavoritesLocalDb._privateConstructor();

  static final FavoritesLocalDb instance = FavoritesLocalDb._privateConstructor();

  static Database? _database;

  Future get database async{
    if(_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async{
      Directory docDirectory = await getApplicationDocumentsDirectory();
      String path = join(docDirectory.path,_databaseName);
      return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate);

  }
  // Favorite({required this.itemId,required this.name, required this.image,required this.type, this.rating = -1.0});
  Future _onCreate(Database db, int version) async{
    await db.execute("CREATE TABLE $_favoritesTable(id INTEGER PRIMARY KEY AUTOINCREMENT, item_id TEXT, name TEXT,image TEXT, type TEXT, rating DOUBLE )");
  }

  @override
  Future<bool>  addToFavorites(Favorite favorite) async{
      Database db = await instance.database;
      // Insert the Dog into the correct table. You might also specify the
      // `conflictAlgorithm` to use in case the same dog is inserted twice.
      //
      // In this case, replace any previous data.
      try{
        await db.insert(
        _favoritesTable,
        favorite.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,);
        return true;
      }
      catch(e){
        return false;
      }
  }

  @override
  Future<List<Favorite>> getFavoriteAttractions() async{
    // from favorites table fetch favorite items where type = 'attraction';
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('SELECT * FROM $_favoritesTable WHERE type = attraction');
    // Convert the List<Map<String, dynamic> into a List<Favorite>.
    return List.generate(maps.length, (i) {
      return Favorite.fromJson(maps[i]);
    });

  }

  @override
  Future<List<Favorite>> getFavoriteHotels() async{
    // from favorites table fetch favorite items where type = 'hotel';
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('SELECT * FROM $_favoritesTable WHERE type = hotel');
    // Convert the List<Map<String, dynamic> into a List<Favorite>.
    return List.generate(maps.length, (i) {
      return Favorite.fromJson(maps[i]);
    });

  }

  @override
  Future getFavoriteTourGuides() async{
    // from favorites table fetch favorite items where type = 'tour_guide';
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('SELECT * FROM $_favoritesTable WHERE type = tour_guide');
    // Convert the List<Map<String, dynamic> into a List<Favorite>.
    return List.generate(maps.length, (i) {
      return Favorite.fromJson(maps[i]);
    });

  }


  @override
  Future removeFromFavorites(String itemId) async{
    Database db = await instance.database;
    // from favorites table remove favorite item where item_id = itemId;
    await db.delete(
      _favoritesTable,
      // Use a `where` clause to delete a specific favorite.
      where: "item_id = ?",
      // Pass the favorites id as a whereArg to prevent SQL injection.
      whereArgs: [itemId],
    );

  }


}