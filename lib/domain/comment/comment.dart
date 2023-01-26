import '../restaurant/restaurant.dart';
import '../user/user.dart';

class Comment {
  late String id;
  late String review;
  late int rating;
  late DateTime createdAt;
  late DateTime updatedAt;
  late User user;
  late Restaurant restaurant;

  Comment({
    required this.id,
    required this.review,
    required this.rating,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    required this.restaurant,
  });

  Comment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    review = json['review'];
    rating = json['rating'];
    createdAt = DateTime.parse(json['created_at']);
    updatedAt = DateTime.parse(json['updated_at']);
    user = User.fromJson(json['user']);
    restaurant = Restaurant.fromJson(json['restaurant']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['review'] = review;
    data['rating'] = rating;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['user'] = user.toJson();
    data['restaurant'] = restaurant.toJson();
    return data;
  }
}