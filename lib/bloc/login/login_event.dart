part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class CreateAccountWithEmailButtonPressed extends LoginEvent {
  final String email;
  final String password;

  CreateAccountWithEmailButtonPressed({@required this.email, @required this.password});

  @override
  List<Object> get props => [email, password];
}

class LoginInWithEmailButtonPressed extends LoginEvent {
  final String email;
  final String password;

  LoginInWithEmailButtonPressed({@required this.email, @required this.password});

  @override
  List<Object> get props => [email, password];
}