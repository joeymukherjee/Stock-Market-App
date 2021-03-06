part of 'trades_bloc.dart';

@immutable
abstract class TradeEvent extends Equatable {
  const TradeEvent();

  @override
  List<Object> get props => [];
}

class PickedPortfolio extends TradeEvent {
  final String portfolioId;

  const PickedPortfolio (this.portfolioId);
  @override
  List<Object> get props => [portfolioId];
}

class EditedTradeGroup extends TradeEvent {
  final String portfolioId;

  const EditedTradeGroup (this.portfolioId);
  @override
  List<Object> get props => [portfolioId];
}

class DeletedTradeGroup extends TradeEvent {
  final String ticker;
  final String portfolioId;

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
class SelectedTrades extends TradeEvent {
  final String portfolioId;
  final String ticker;

  @override
  List<Object> get props => [portfolioId, ticker];

  @override
  String toString() {
    return 'SelectedTrades { portfolioId: $portfolioId, ticker: $ticker }';
  }

  SelectedTrades ({@required this.portfolioId, @required this.ticker});
}

class EditedTrades extends TradeEvent {
  final String portfolioId;
  final String ticker;

  @override
  List<Object> get props => [portfolioId, ticker];

  @override
  String toString() {
    return 'EditedTrades { portfolioId: $portfolioId, ticker: $ticker }';
  }

  EditedTrades ({@required this.portfolioId, @required this.ticker});
}

class DeletedTrade extends TradeEvent {
  final String id;
  final String portfolioId;
  final String ticker;

  @override
  List<Object> get props => [id, portfolioId, ticker];

  @override
  String toString() {
    return 'DeletedTrade { id: $id, portfolioId: $portfolioId, ticker: $ticker }';
  }

  DeletedTrade ({@required this.id, @required this.portfolioId, @required this.ticker});
}

class MergeMultipleTrades extends TradeEvent {
  final String portfolioId;
  final List<Trade> trades;

  @override
  List<Object> get props => [portfolioId, trades];

  MergeMultipleTrades ({@required this.portfolioId, @required this.trades});
}

class SaveFolderOnTradeGroupPage extends TradeEvent {

  final PortfolioFolderModel model;

  SaveFolderOnTradeGroupPage({
    @required this.model
  });
}

class ReorderedTradeGroups extends TradeEvent {
  final List<TradeGroup> tradeGroups;

  ReorderedTradeGroups({
    @required this.tradeGroups
  });
}