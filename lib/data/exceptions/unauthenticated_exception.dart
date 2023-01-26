class UnauthenticatedException implements Exception {
  final String message;

  UnauthenticatedException({
    this.message = "You must be logged in to do this action",
  });
}
