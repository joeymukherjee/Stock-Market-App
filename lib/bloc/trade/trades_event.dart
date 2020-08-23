part of 'trades_bloc.dart';

@immutable
abstract class TradeEvent extends Equatable {
  const TradeEvent();

  @override 
  List<Object> get props => [];
}

class TradesLoaded extends TradeEvent {}
class PickedPortfolio extends TradeEvent {
  final int portfolioId;

  const PickedPortfolio (this.portfolioId);
  @override
  List<Object> get props => [portfolioId];
}
class CreatedTransaction extends TradeEvent {}
class DidTrade extends TradeEvent {
  final Trade trade;

  const DidTrade (this.trade);

  @override 
  List<Object> get props => [trade];

  @override
  String toString() {
    return 'DidTrade { trade: $trade }';
  }
}
class SavedTrade extends TradeEvent {

  final Trade trade;

  SavedTrade({
    @required this.trade
  });
}
