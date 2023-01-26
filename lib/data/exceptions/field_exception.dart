class FieldException implements Exception {
  late String message;
  late List<FieldError> fieldErrors;

  FieldException({required this.message, required this.fieldErrors});

  FieldException.fromJson(Map<String, dynamic> json) {
    message = json["message"];
    fieldErrors = [];
    if (json['errors'] != null) {
      json['errors'].forEach((e) {
        fieldErrors.add(FieldError.fromJson(e));
      });
    }
  }
}

class FieldError {
  late String field;
  late String error;

  FieldError({required this.field, required this.error});

  FieldError.fromJson(Map<String, dynamic> json) {
    field = json["field"];
    error = json["error"];
  }
}
