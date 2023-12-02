import 'dart:async';
import 'dart:core';
import 'dart:developer';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'food_model.dart';

class DataBaseHelper {
  static const int _version = 6; // Increment version to trigger an upgrade
  static const String _dbName = "Food.db";

  //all functions are running in async so that they avoid running on the Main thread.
  //this is the function to start an instance of the db
  static Future<Database> _getDB() async {
    return openDatabase(join(await getDatabasesPath(), _dbName),
      onCreate: (db, version) async {
        //first, query the database and make sure that the tables dont exists, if not then create them
        var foodTable = await db.query('sqlite_master', where: 'name = ?', whereArgs: ['Food']);
        if (foodTable.isEmpty) {
          await db.execute(
              "CREATE TABLE Food(ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT, CALORIES INTEGER);");
        }
        var plansTable = await db.query('sqlite_master', where: 'name = ?', whereArgs: ['Plans']);
        if (plansTable.isEmpty) {
          await db.execute(
              "CREATE TABLE Plans(ID INTEGER PRIMARY KEY AUTOINCREMENT, PLAN TEXT, TARGET_CALORIES INTEGER, DATE TEXT);");
        }
      },
      //pass version of DB
      version: _version,
      //now, i created a onupgrade function for the DB since I was adding tables and columns
      //I would call this by increasing the value of the _version string constant and changing the if statement below
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion == 5 && newVersion == 6) {
          await db.execute(
              "CREATE TABLE Food(ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT, CALORIES INTEGER);");
        }
      },
    );
  }

  //function to adda  single food object tot he DB
  //this was only used at the beginning to import all my values into the DB
  static Future<int> addFood(Food food) async {
    //call DB
    final db = await _getDB();
    //log the Food object contetns
    var Log = food.toString();
    log("insert data: $Log");
    //insert the data
    return await db.insert("Food", food.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  //updateFood method for updating a single entry in the DB based on ID of object
  static Future<int> updateFood(Food food) async {
    final db = await _getDB();
    return await db.update("Food",
        food.toJson(),
        where: 'id = ?',
        whereArgs: [food.id],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  //deleteFood method for deleting a single entry based on ID
  static Future<int> deleteFood(Food food) async {
    final db = await _getDB();
    return await db.delete("Food",
      where: 'id = ?',
      whereArgs: [food.id],
    );
  }

  //took me a while to get working properly, gets all rows in food table for displaying in dropdown menu
  static Future<List<Food>?> getAllFood() async {
    final db = await _getDB();
    //create a list of a map and save query results to it
    final List<Map<String,dynamic>> maps = await db.rawQuery("SELECT * FROM Food");
    if (maps.isEmpty){
      return null;
    }

    //return a list generated based on the list of mapping from the DB
    //calls my fromJSON method to parse it into a List<String>
    return List.generate(maps.length, (index) => Food.fromJson(maps[index]));
  }

  //legacy function to add a single food item based on ID
  static Future<List<Food>> getFood(int ID) async {
    final db = await _getDB();
    final List<Map<String,dynamic>> maps = await db.query("SELECT FROM Food WHERE ID = '$ID'");

    if (maps.isEmpty){
    }

    return List.generate(maps.length, (index) => Food.fromJson(maps[index]));
  }

  //method to save meal plan to DB
  static Future<void> saveMealPlan(
      List<String> mealPlan, int targetCalories, DateTime selectedDate) async {
    final db = await _getDB();

    //convert total list of mealplan (all food items) into list for insert into DB
    final String planString = mealPlan.join(', ');

    //insert into DB, key:value pairs
    await db.insert("Plans", {
      'PLAN': planString,
      'TARGET_CALORIES': targetCalories,
      'DATE': selectedDate.toIso8601String()
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  //method to grab list of meal plans from DB
  static Future<List<String>> getMealPlan(DateTime selectedDate) async {
    final db = await _getDB();

    // Query the database for the meal plan on the selected date
    final List<Map<String, dynamic>> result = await db.rawQuery(
        "SELECT * FROM Plans WHERE DATE = ?",
        [selectedDate.toIso8601String()]);

    if (result.isEmpty) {
      // If no meal plan found, return an empty list
      return [];
    } else {
      // Extract the plan string from the result and split it into a list
      final List<String> mealPlan =
      result[0]['PLAN'].toString().split(', ');

      return mealPlan;
    }
  }
}
