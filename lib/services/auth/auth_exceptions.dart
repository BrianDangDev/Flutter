//login exceptions

class UserNotFoundAuthException implements Exception {}

class WrongPassworddAuthException implements Exception {}

//register exceptions

class EmailAlreadyInUseAuthException implements Exception {}

class InvalidEmailAuthException implements Exception {}

class WeakPasswordAuthException implements Exception {}

//generic exceptions

class GenericAuthException implements Exception {}

class UserNotLoggedInAuthException implements Exception {}
