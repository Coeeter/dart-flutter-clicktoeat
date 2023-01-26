import '../common/image.dart';

class User {
  late String id;
  late String username;
  late String email;
  late Image? image;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.image,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    email = json['email'];
    image = json['image'] != null ? Image.fromJson(json['image']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['username'] = username;
    data['email'] = email;
    if (image != null) {
      data['image'] = image!.toJson();
    }
    return data;
  }
}
