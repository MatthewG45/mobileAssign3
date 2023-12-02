import 'dart:developer';

//this is the class i created to model the contents of a specific food item.
//this is necessary because I wanted to contain more than one variable type in a list.

//declare class and instantiate variables
class Food{
  final int id;
  final String name;
  final int calories;

  //create constructor and initialize values
  const Food({
    required this.id,
    required this.name,
    required this.calories
  });

  //this method is to convert a json file to a Food object for exporting form the DB
  factory Food.fromJson(Map<String, dynamic> json) {
    if (json['ID'] == null || json['NAME'] == null || json['CALORIES'] == null) {
      throw FormatException("Invalid JSON format for Food");
    }

    return Food(
      id: json['ID'],
      name: json['NAME'],
      calories: json['CALORIES'],
    );
  }

  //this method converts a Food object to a Map for inputting to the database.
  Map<String,dynamic> toJson() => {
    'id': id,
    'name': name,
    'calories': calories
  };
}