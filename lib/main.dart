import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'Meal.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        appBar: AppBar(
          title: Text("Test!"),
        ),
        body: MealWidget()
      ),
    );
  }
}

class MealWidget extends StatefulWidget {
  const MealWidget({Key? key}) : super(key: key);

  @override
  _MealWidgetState createState() => _MealWidgetState();
}

class _MealWidgetState extends State<MealWidget> {
  late Future<List<Meal>> _items;

  @override
  void initState() {
    super.initState();
    _items = fetchMeals();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _items,
      builder: (context, AsyncSnapshot<List<Meal>> snapshot) {
        if(snapshot.connectionState == ConnectionState.none) {
          return Container(
            child: Center(
              child: Text("No connection!"),
            ),
          );
        }
        if(snapshot.connectionState == ConnectionState.active || snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            child: Center(
              child: Text("Loading..."),
            ),
          );
        }
        if (snapshot.hasData) {
          return ListView.builder(
              itemCount: snapshot.data!.length,
              padding: EdgeInsets.all(16.0),
              itemBuilder: (context, index) {
                var item = snapshot.data![index];
                print(item.toString());
                return ListTile(
                  leading: Icon(Icons.food_bank_outlined),
                  title: Text(item.title),
                  subtitle: Text(item.location),
                );
              });
        }
        // spinner for uncompleted state
        return Container();
      },
    );
  }
}

Future<List<Meal>> fetchMeals() async {
  final response = await http.get(Uri.parse("https://www.mensa-kl.de/api.php?date=all&format=json"));

  if (response.statusCode == 200) {
    //print(jsonDecode(response.body));
    Iterable l = jsonDecode(response.body);
    List<Meal> meals = List<Meal>.from(l.map((model) => Meal.fromJson(model)));
    return meals;
  } else {
    throw Exception('Failed to load meals!');
  }
}



