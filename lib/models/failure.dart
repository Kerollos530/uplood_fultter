class Failure {
  final String message;

  const Failure(this.message);

  @override
  String toString() => message;
}

class NetworkFailure extends Failure {
  const NetworkFailure() : super('Please check your internet connection.');
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class ServerFailure extends Failure {
  const ServerFailure()
    : super('Something went wrong on the server. Please try again.');
}
