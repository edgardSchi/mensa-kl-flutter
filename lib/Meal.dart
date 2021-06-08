
class Meal {
  final String date;
  final String location;
  final String title;
  final String price;
  final String image;
  final String icon;

  Meal({
    required this.date,
    required this.location,
    required this.icon,
    required this.image,
    required this.price,
    required this.title
});

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      date: json['date'],
      location: json['loc'],
      icon: json['icon'],
      image: json['image'],
      price: json['price'],
      title: json['title'],
    );
  }

  @override
  String toString() {
    return title + " : " + " date ";
  }
}