part of 'trades_bloc.dart';

@immutable
abstract class TradeEvent extends Equatable {
  const TradeEvent();

  @override 
  List<Object> get props => [];
}

// class TradesLoaded extends TradeEvent {}
class PickedPortfolio extends TradeEvent {
  final int portfolioId;

  const PickedPortfolio (this.portfolioId);
  @override
  List<Object> get props => [portfolioId];
}

class EditedTradeGroup extends TradeEvent {
  final int portfolioId;

  const EditedTradeGroup (this.portfolioId);
  @override
  List<Object> get props => [portfolioId];
}

class DeletedTradeGroup extends TradeEvent {
  final String ticker;
  final int portfolioId;

  const DeletedTradeGroup ({this.ticker, this.portfolioId});
  @override
  List<Object> get props => [ticker, portfolioId];
}

class AddedTransaction extends TradeEvent {}
class FinishedTransaction extends TradeEvent {}
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

class EditedTrades extends TradeEvent {
  final int portfolioId;
  final String ticker;

  EditedTrades ({@required this.portfolioId, @required this.ticker});
}
