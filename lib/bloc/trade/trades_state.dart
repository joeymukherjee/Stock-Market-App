part of 'trades_bloc.dart';

@immutable
abstract class TradesState extends Equatable {
  const TradesState();

  @override 
  List<Object> get props => [];
}
class TradesInitial extends TradesState {}
class TradesEmpty extends TradesState {}
class TradesLoadSuccess extends TradesState {
  final List<TradeGroup> tradeGroups;

  const TradesLoadSuccess(this.tradeGroups);

  @override 
  List<Object> get props => [tradeGroups];

  @override
  String toString() {
    return 'TradesLoadSuccess { trades: $tradeGroups }';
  }
}
class TradesEditing extends TradesState {}
class TradeGroupLoadedEditing extends TradesState {
  final List<TradeGroup> tradeGroups;

  const TradeGroupLoadedEditing(this.tradeGroups);

  @override
  List<Object> get props => [tradeGroups];

  @override
  String toString() {
    return 'TradeGroupLoadedEditing { trades: $tradeGroups }';
  }
}

class TradesAdding extends TradesState {}
class TradesFinishedEditing extends TradesState {}
class TradesValidTransaction extends TradesState {
  final Trade trade;
  const TradesValidTransaction(this.trade);

  @override 
  List<Object> get props => [trade];
}
class TradesSavedOkay extends TradesState {}
class TradesFailure extends TradesState {
  final String message;

  TradesFailure({
    @required this.message
  });
}