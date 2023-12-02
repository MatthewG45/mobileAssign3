import 'dart:math';

import 'package:flutter/material.dart';
import 'dataBaseHelper.dart';

import 'food_model.dart';
//matthew gardiner
//id: 100768198



//all of this is auto0-generated
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

//here is where i started development
class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  //instantiating lists to contain data for the various views
  List<String> selectedList = [];
  List<String> mealList = [];
  String selectedItem = "McMuffin";
  List<String> fooditems = [];
  List<Food> fooditems2 = [];

  int targetCalories = 0;
  DateTime selectedDate = DateTime.now();

  //update the view of the home page by putting the list refresh in setstate
  void getStringList() async {
    var tempList = await DataBaseHelper.getAllFood();
    setState(() {
      fooditems2 = tempList!;
      fooditems = fooditems2.map((food) => "${food.id}, ${food.name}, ${food.calories}").toList();
    });
  }

  //delete a selected food item
  void _deleteItem(int index) {
    setState(() {
      selectedList.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      //make this a single child scroll so you can scroll the entire home page
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            //creating a dropdownbutton and calling the database to fill its item list
            DropdownButton<String>(
              //first, map each item to each dropdown option
              items: fooditems.map((item) => DropdownMenuItem<String>(
                value: item,
                child: Text(item, style: TextStyle(fontSize: 16)),
              )).toList(),
              //then, call these functions in a setstate to refresh page and display items when item is clicked
              onChanged: (item) {
                setState(() {
                  selectedItem = item!;
                  getStringList();
                  selectedList.add(fooditems[fooditems.indexOf(selectedItem)]);
                });
              },
            ),
            //text form field for grabbing user input
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Target Calories per Day'),
              //when input is found, parse into int
              onChanged: (value) {
                setState(() {
                  targetCalories = int.tryParse(value) ?? 0;
                });
              },
            ),
            //spacer
            SizedBox(height: 16),
            //add button to call on DB to insert new meal plan with selected items list
            ElevatedButton(
              onPressed: () async {
                //save the meal plan to the DB
                await DataBaseHelper.saveMealPlan(selectedList, targetCalories, selectedDate);
              },
              child: Text("Save Meal Plan", style: TextStyle(fontSize: 16)),
            ),
            //spacer
            SizedBox(height: 16),
            //add button to grab user selected date, set to today if not chosen
            ElevatedButton(
              onPressed: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (picked != null && picked != selectedDate) {
                  setState(() {
                    selectedDate = picked;
                  });
                }
              },
              child: Text("Select Date", style: TextStyle(fontSize: 16)),
            ),
            //spacer
            SizedBox(height: 16),
            //selected food items list display
            ListView.separated(
              itemCount: selectedList.length,
              shrinkWrap: true,
              //separate each item by a divider
              separatorBuilder: (BuildContext context, int index) => Divider(),
              //start building each item per index
              itemBuilder: (context, index) {
                //before we decalre the structure of items, we set a gesture listener for user input
                return GestureDetector(
                  //here is the action, on long press delete the selected item from list
                  onLongPress: () => _deleteItem(index),
                  //create a listtile for each item to be displayed it
                  child: ListTile(
                    //visual density just to reduce size of list items
                    visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                    title: Text(selectedList[index]),
                  ),
                );
              },
            ),
            //spacer
            SizedBox(height: 16),
            //display list of meal plans for selected date
            FutureBuilder<List<String>>(
              future: DataBaseHelper.getMealPlan(selectedDate),
              builder: (context, snapshot) {
                //make a snapshot to wait for async task to complete
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) { //if the query is not null and is not empty
                  return Column(
                    children: [
                      //text as a title before and on top of the listview
                      Text("Meal Plan for ${selectedDate.toLocal()}"),
                      ListView.separated(
                        itemCount: snapshot.data!.length,
                        shrinkWrap: true,
                        separatorBuilder: (BuildContext context, int index) => Divider(),
                        itemBuilder: (context, index) {
                          return ListTile(
                            visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                            title: Text(snapshot.data![index]),
                          );
                        },
                      ),
                    ],
                  );
                } else {
                  return Text("No meal plan for ${selectedDate.toLocal()}");
                }
              },
            ),
          ],
        ),
      ),
      //legacy code, but i still use it to update the dropdown menu
      floatingActionButton: FloatingActionButton(
        onPressed: getStringList,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
