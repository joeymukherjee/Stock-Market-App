import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationException implements Exception{
  final String message;

  AuthenticationException({this.message = 'Unknown error occurred. '});
}

abstract class AuthenticationService extends Cubit {
  AuthenticationService() : super (null);
  Future<User> getCurrentUser();
  Future<User> signInWithEmailAndPassword(String email, String password);
  Future<void> signOut();
}

class FirebaseEmailPassword extends AuthenticationService {
  FirebaseEmailPassword () : super ();

  @override
  Future<User> getCurrentUser() async {
    return FirebaseAuth.instance.currentUser;
  }

  Future<User> createUserWithEmailAndPassword(String email, String password) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw AuthenticationException(message: 'The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        throw AuthenticationException(message: 'The account already exists for that email.');
      }
    } catch (e) {
      print(e.toString());
    }
    return FirebaseAuth.instance.currentUser;
  }

  @override
  Future<User> signInWithEmailAndPassword(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw AuthenticationException(message: 'We don\'t have an account for you.  Create one!');
      } else if (e.code == 'email-already-in-use') {
        throw AuthenticationException(message: 'The account already exists for that email.');
      }
      throw AuthenticationException(message: e.message);
    } catch (e) {
      throw AuthenticationException(message: e.toString());
    }
    return FirebaseAuth.instance.currentUser;
  }
  @override
  Future<void> signOut() {
    return FirebaseAuth.instance.signOut();
  }
}

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  final AuthenticationService _authenticationService;

  AuthenticationBloc(authenticationService)
      : _authenticationService = authenticationService, super(AuthenticationInitial());

  @override
  Stream<AuthenticationState> mapEventToState(AuthenticationEvent event) async* {
    if (event is AppLoaded) {
      yield* _mapAppLoadedToState(event);
    }

    if (event is UserLoggedIn) {
      yield* _mapUserLoggedInToState(event);
    }

    if (event is UserLoggedOut) {
      yield* _mapUserLoggedOutToState(event);
    }
  }

  Stream<AuthenticationState> _mapAppLoadedToState(AppLoaded event) async* {
    yield AuthenticationLoading();
    try {
      await Future.delayed(Duration(milliseconds: 500)); // a simulated delay
      final currentUser = await _authenticationService.getCurrentUser();

      if (currentUser != null) {
        yield AuthenticationAuthenticated(user: currentUser);
      } else {
        yield AuthenticationNotAuthenticated();
      }
    } catch (e) {
      yield AuthenticationFailure(message: e.message ?? 'An unknown error occurred');
    }
  }

  Stream<AuthenticationState> _mapUserLoggedInToState(UserLoggedIn event) async* {
    yield AuthenticationAuthenticated(user: event.user);
  }

  Stream<AuthenticationState> _mapUserLoggedOutToState(UserLoggedOut event) async* {
    await _authenticationService.signOut();
    yield AuthenticationNotAuthenticated();
  }
}