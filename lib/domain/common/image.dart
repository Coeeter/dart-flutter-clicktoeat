class Image {
  late int id;
  late String key;
  late String url;

  Image({
    required this.id,
    required this.key,
    required this.url,
  });

  Image.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    key = json['key'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['key'] = key;
    data['url'] = url;
    return data;
  }
}