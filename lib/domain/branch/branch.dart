import '../restaurant/restaurant.dart';

class Branch {
  late String id;
  late double latitude;
  late double longitude;
  late String address;
  late Restaurant restaurant;

  Branch({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.restaurant,
  });

  Branch.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    address = json['address'];
    restaurant = Restaurant.fromJson(json['restaurant']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['address'] = address;
    data['restaurant'] = restaurant.toJson();
    return data;
  }
}