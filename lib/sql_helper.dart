import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;


class SQLHelper {

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'dbemp.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        print("database created successfully");
        await createTables(database);
      },
    );
  }

  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE empData(
        id INTEGER PRIMARY KEY NOT NULL,
        email TEXT,
        first_name TEXT,
        last_name TEXT,
        avatar TEXT
         )
      """);
    print("table created successfully");
  }


  // Create new item (journal)
  static Future<int> createItem(int id,String email, String first_name,String last_name, String avatar) async {
    final db = await SQLHelper.db();
    final data = {"id": id,'email': email,'first_name':first_name,'last_name':last_name,'avatar':avatar};
    final Id = await db.insert('empData', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return Id;
  }

  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await SQLHelper.db();
    return db.query('empData', orderBy: "id");
  }

  Future<List> getEmpData() async {
    final db = await SQLHelper.db();
    final List<Map<String, dynamic?>> queryResult = await db.query('empData');
    return queryResult;
  }


  Future<List<Map<String, dynamic>>> queryAllRows() async {
    final db = await SQLHelper.db();
    return await db.query("empData");
  }


  // Read a single item by id
  // The app doesn't use this method but I put here in case you want to see it
  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await SQLHelper.db();
    print("this is selected: ${db.query('emp', where: "id = ?", whereArgs: [id], limit: 1)}");
    return db.query('empData', where: "id = ?", whereArgs: [id], limit: 1);
  }

  // Update an item by id
  static Future<int> updateItem(
      int id, String email, String first_name,String last_name,String avatar) async {
    final db = await SQLHelper.db();

    final data = {
      'email': email,
      'first_name': first_name,
      'last_name': last_name,
      'avatar' : avatar,
    };

    final result =
    await db.update('empData', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  // Delete
  static Future<void> deleteItem(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("empData", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }
}