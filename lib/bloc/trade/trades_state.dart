part of 'trades_bloc.dart';

@immutable
abstract class TradesState extends Equatable {
  const TradesState();

  @override 
  List<Object> get props => [];
}
class TradesInitial extends TradesState {}
class TradesEmpty extends TradesState {}
class TradeGroupsLoadSuccess extends TradesState {
  final List<TradeGroup> tradeGroups;

  const TradeGroupsLoadSuccess(this.tradeGroups);

  @override 
  List<Object> get props => [tradeGroups];

  @override
  String toString() {
    return 'TradesLoadSuccess { trades: $tradeGroups }';
  }
}
class TradesEditing extends TradesState {}
class TradeGroupsLoadedEditing extends TradesState {
  final List<TradeGroup> tradeGroups;

  const TradeGroupsLoadedEditing(this.tradeGroups);

  @override
  List<Object> get props => [tradeGroups];

  @override
  String toString() {
    return 'TradeGroupsLoadedEditing { trades: $tradeGroups }';
  }
}
class TradesLoading extends TradesState {}
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

class TradeEditing extends TradesState {}
class TradeGroupLoadedEditing extends TradesState {
  final TradeGroup tradeGroup;

  const TradeGroupLoadedEditing (this.tradeGroup);

  @override
  List<Object> get props => [tradeGroup];

  @override
  String toString() {
    return 'TradeGroupLoadedEditing { tradeGroup: $tradeGroup }';
  }
}
class TradeGroupLoaded extends TradesState {
  final TradeGroup tradeGroup;

  const TradeGroupLoaded (this.tradeGroup);

  @override
  List<Object> get props => [tradeGroup];

  @override
  String toString() {
    return 'TradeGroup { tradeGroup: $tradeGroup }';
  }
}