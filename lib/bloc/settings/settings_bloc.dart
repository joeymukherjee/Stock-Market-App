import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

@immutable
abstract class SettingsEvent extends Equatable {}
class ToggledThemeEvent extends SettingsEvent {
  @override
  List<Object> get props => [];
}

@immutable
abstract class SettingsState extends Equatable {
  final bool isNight;
  const SettingsState(this.isNight);

  @override
  List<Object> get props => [isNight];
}

class SettingsInitial extends SettingsState {
  const SettingsInitial (bool isNight) : super (isNight);
}
class SettingsToggleTheme extends SettingsState {
  const SettingsToggleTheme (bool isNight) : super (isNight);
}

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  bool _isNight;

  SettingsBloc(this._isNight) : super(SettingsInitial(_isNight));

  @override
  Stream<SettingsState> mapEventToState(SettingsEvent event) async* {

    if (event is ToggledThemeEvent) {
      _toggleTheme();
      _setTheme();
      yield SettingsToggleTheme(_isNight);
    }
  }

  void _toggleTheme() {
    _isNight = !_isNight;
  }

  void _setTheme() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('theme', _isNight);
  }
}
