class FieldException implements Exception {
  late String message;
  late List<FieldErrorItem> fieldErrors;

  FieldException({required this.message, required this.fieldErrors});

  FieldException.fromJson(Map<String, dynamic> json) {
    message = json["message"];
    fieldErrors = [];
    if (json['errors'] != null) {
      json['errors'].forEach((e) {
        fieldErrors.add(FieldErrorItem.fromJson(e));
      });
    }
  }
}

class FieldErrorItem {
  late String field;
  late String error;

  FieldErrorItem({required this.field, required this.error});

  FieldErrorItem.fromJson(Map<String, dynamic> json) {
    field = json["field"];
    error = json["error"];
  }
}
