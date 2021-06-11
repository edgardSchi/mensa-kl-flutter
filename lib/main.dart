import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'Meal.dart';

const IMAGE_URL = "https://www.mensa-kl.de/mimg/";

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        appBar: AppBar(
          title: Text("Mensa-KL"),
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
    var _lastDate = "";
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
                if (_lastDate != item.date) {
                  _lastDate = item.date;
                  return Container(
                    child: Column(
                      children: <Widget>[
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(convertDate(item.date)),
                        ),
                        buildMealWidget(item),
                      ],
                    ),
                  );
                } else {
                  return buildMealWidget(item);
                }

                print(item.toString());
                //return buildMealWidget(item);
              });
        }
        // spinner for uncompleted state
        return Container();
      },
    );
  }

  Widget buildMealWidget(Meal meal) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Expanded(
              child: Container(
                alignment: Alignment.centerLeft,
                child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  backgroundImage: getImage(meal.image),
                  radius: 55,
                ),
      ),

          ),
          Expanded(
              child: Column(
                children: <Widget>[
                  Text(meal.title,
                    style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.3),
                  ),
                  Container(
                      alignment: Alignment.bottomLeft,
                      child: Text(meal.price + " €")),
                ],
          ),
          ),
        ],
      ),
    );
  }
}

ImageProvider getImage(String url) {
  if (url.isEmpty) {
    return NetworkImage("https://upload.wikimedia.org/wikipedia/commons/thumb/e/e1/Noun_Project_question_mark_icon_1101884_cc.svg/132px-Noun_Project_question_mark_icon_1101884_cc.svg.png");
  } else {
    return NetworkImage(IMAGE_URL + url);
  }
}

Future<List<Meal>> fetchMeals() async {
  final response = await http.get(Uri.parse("https://www.mensa-kl.de/api.php?date=all&format=json"));

  if (response.statusCode == 200) {
    Iterable l = jsonDecode(response.body);
    print("Sending request!");
    List<Meal> meals = List<Meal>.from(l.map((model) => Meal.fromJson(model)));
    return meals;
  } else {
    throw Exception('Failed to load meals!');
  }
}


String convertDate(String date) {
  List<String> s = date.split("-");
  return s[2] + "." + s[1] + "." + s[0];
}


