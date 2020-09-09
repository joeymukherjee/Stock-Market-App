import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import '../authentication/authentication_bloc.dart';
part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthenticationBloc _authenticationBloc;
  final AuthenticationService _authenticationService;

  LoginBloc(AuthenticationBloc authenticationBloc, AuthenticationService authenticationService)
      : assert(authenticationBloc != null),
        assert(authenticationService != null),
        _authenticationBloc = authenticationBloc,
        _authenticationService = authenticationService,
        super (null);

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is LoginInWithEmailButtonPressed) {
      yield* _mapLoginWithEmailToState(event);
    }
    if (event is CreateAccountWithEmailButtonPressed) {
      yield* _mapCreateAccountWithEmailToState(event);
    }
  }

  Stream<LoginState> _mapCreateAccountWithEmailToState(CreateAccountWithEmailButtonPressed event) async* {
    yield LoginLoading();
    try {
      final auth = _authenticationService as FirebaseEmailPassword;
      final user = await auth.createUserWithEmailAndPassword(event.email, event.password);
      if (user != null){
        _authenticationBloc.add(UserLoggedIn(user: user));
        yield LoginSuccess();
        yield LoginInitial();
      }else {
        yield LoginFailure(error: 'Something very weird just happened');
      }
    } on AuthenticationException catch(e){
      print (e);
      yield LoginFailure(error: e.message);
    } catch (err) {
      yield LoginFailure(error: err.message ?? 'An unknown error occured');
    }
  }

  Stream<LoginState> _mapLoginWithEmailToState(LoginInWithEmailButtonPressed event) async* {
    yield LoginLoading();
    try {
      final user = await _authenticationService.signInWithEmailAndPassword(event.email, event.password);
      if (user != null){
        _authenticationBloc.add(UserLoggedIn(user: user));
        yield LoginSuccess();
        yield LoginInitial();
      }else {
        yield LoginFailure(error: 'Something very weird just happened');
      }
    } on AuthenticationException catch(e){
      print (e);
      yield LoginFailure(error: e.message);
    } catch (err) {
      yield LoginFailure(error: err.message ?? 'An unknown error occured');
    }
  }
}