part of 'trades_bloc.dart';

@immutable
abstract class TradesState extends Equatable {
  const TradesState();

  @override 
  List<Object> get props => [];
}
class TradesInitial extends TradesState {}
class TradesEmpty extends TradesState {}
class TradesLoadInProgress extends TradesState {}
class TradesLoadSuccess extends TradesState {
  final List<Trade> trades;

  const TradesLoadSuccess([this.trades = const []]);

  @override 
  List<Object> get props => [];

  @override
  String toString() {
    return 'TradesLoadSuccess { trades: $trades }';
  }
}
class TradesEditing extends TradesState {}
class TradesAdding extends TradesState {}
class TradesFinishedEditing extends TradesState {}
class TradesValidTransaction extends TradesState {
  final Trade trade;
  const TradesValidTransaction(this.trade);

  @override 
  List<Object> get props => [trade];
}
class TradesSavedOkay extends TradesState {}
class TradesLoadFailure extends TradesState {
  final String message;

  TradesLoadFailure({
    @required this.message
  });
}