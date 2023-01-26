import '../branch/branch.dart';
import '../common/image.dart';

class Restaurant {
  late String id;
  late String name;
  late String description;
  late List<Branch> branches;
  late Image? image;

  Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.branches,
    required this.image,
  });

  Restaurant.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    branches = [];
    if (json['branches'] != null) {
      json['branches'].forEach((b) {
        branches.add(Branch.fromJson(b));
      });
    }
    image = json['image'] != null ? Image.fromJson(json['image']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['branches'] = branches.map((b) => b.toJson()).toList();
    if (image != null) {
      data['image'] = image!.toJson();
    }
    return data;
  }
}
