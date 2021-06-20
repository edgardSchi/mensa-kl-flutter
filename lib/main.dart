import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'Meal.dart';

const IMAGE_URL = "https://www.mensa-kl.de/mimg/";

void main() => runApp(MyApp());

/// Main Widget
class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mensa-KL',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.lightGreen,
        accentColor: Colors.greenAccent,

        textTheme: TextTheme(
          headline3: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          headline4: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          headline6: TextStyle(fontSize: 12)
        ),
      ),
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
                // this sometimes leads to a bug where the items are not listed under the correct dates
                // possible fix with a custom separator?
                if (_lastDate != item.date) {
                  _lastDate = item.date;
                  return Container(
                    child: Column(
                      children: <Widget>[
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(convertDate(item.date), style: Theme.of(context).textTheme.headline3,),
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
      child: GestureDetector(
        onTap: () {
          showMealDialog(context, meal);
        },
        child: Row(
          children: <Widget>[
            Expanded(
              child: Container(
                alignment: Alignment.centerLeft,
                child: MealImage.defaultShadow(meal.image),
              ),
            ),
            Expanded(
              child: Column(
                children: <Widget>[
                  Text(meal.title,
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  Container(
                      alignment: Alignment.bottomLeft,
                      child: Text(meal.price + " €", style: Theme.of(context).textTheme.headline6,)),
                ],
              ),
            ),
          ],
        ),
      ),

    );
  }
}
/// TODO: Cache images
ImageProvider getImage(String url) {
  if (url.isEmpty) {
    return NetworkImage("https://upload.wikimedia.org/wikipedia/commons/thumb/e/e1/Noun_Project_question_mark_icon_1101884_cc.svg/132px-Noun_Project_question_mark_icon_1101884_cc.svg.png");
  } else {
    return NetworkImage(IMAGE_URL + url);
  }
}

/// Shows a dialog with the meals details
showMealDialog(BuildContext context, Meal meal) {
  showGeneralDialog(
    barrierLabel: "Label",
    barrierDismissible: true,
    barrierColor: Colors.black45.withOpacity(0.5),
    transitionDuration: Duration(milliseconds: 300),
    context: context,
    pageBuilder: (context, anim1, anim2) {
      return Align(
        alignment: Alignment.center,
        child: Container(
          height: 300,
          child: SizedBox.expand(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    child: MealImage(meal.image, BoxShadow(blurRadius: 2, color: Colors.black, spreadRadius: 1)),
                  ),

                  Container(
                    margin: const EdgeInsets.all(20),
                    child: Text(meal.title, style: Theme.of(context).textTheme.headline3, textAlign: TextAlign.center,),
                  ),
                  Container(
                      child: Text("Preis: " + meal.price + " €", style: Theme.of(context).textTheme.headline4, textAlign: TextAlign.center,)
                  ),
                  Container(
                      child: Text("Ausgabe: " + meal.location, style: Theme.of(context).textTheme.headline4, textAlign: TextAlign.center,)
                  ),
                ],
              ),
          ),
          margin: EdgeInsets.only(left: 12, right: 12),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(40),
          ),
        ),
      );
    },
    transitionBuilder: (context, anim1, anim2, child) {
      return SlideTransition(
        position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim1),
        child: child,
      );
    },
  );
}


/// Fetch the meals asynchronous
Future<List<Meal>> fetchMeals() async {
  final response = await http.get(Uri.parse("https://www.mensa-kl.de/api.php?date=all&format=json"));

  if (response.statusCode == 200) {
    Iterable l = jsonDecode(response.body);
    print(response.body);
    List<Meal> meals = List<Meal>.from(l.map((model) => Meal.fromJson(model)));
    return meals;
  } else {
    throw Exception('Failed to load meals!');
  }
}

///  Convert string of the date from format "YYYY-MM-DD"" to "DD.MM.YYYY"
String convertDate(String date) {
  List<String> s = date.split("-");
  return s[2] + "." + s[1] + "." + s[0];
}
/// Widget of the meals image
class MealImage extends StatelessWidget {

  final String icon;
  final BoxShadow shadow;

  MealImage(this.icon, this.shadow);

  MealImage.defaultShadow(String icon) : this(icon, BoxShadow(blurRadius: 10, color: Colors.black, spreadRadius: 1));

  @override
  Widget build(BuildContext context) {
    return Container (
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [shadow],
      ),
      child: FittedBox(
        fit: BoxFit.contain,
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          backgroundImage: getImage(icon),
          radius: 55,
        ),
      ),

    );
  }
}


