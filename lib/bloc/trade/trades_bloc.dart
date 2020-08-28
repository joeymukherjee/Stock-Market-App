import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:sma/models/trade/trade.dart';
import 'package:sma/models/trade/trade_group.dart';
import 'package:sma/respository/trade/trades_repo.dart';

part 'trades_event.dart';
part 'trades_state.dart';

class TradesBloc extends Bloc<TradeEvent, TradesState> {

  final TradesRepository repository = SembastTradesRepository ();
  TradesBloc () : super (TradesInitial());

  @override
  Stream<TradesState> mapEventToState(TradeEvent event) async*
  {
    if (event is TradesLoaded) {
      yield* _mapTradesLoadedToState();
    }
    if (event is DidTrade) {
      yield* _mapDidTradeToState(event);
    }
    if (event is PickedPortfolio) {
      yield TradesLoading();
      yield* _mapPickedPortfolioToState(event);
    }
    if (event is AddedTransaction) {
      yield* _mapAddedTransactionToState();
    }
    if (event is FinishedTransaction) {
      yield* _mapFinishedTransactionToState();
    }
    if (event is EditedTradeGroup) {
      yield* _mapEditedTradeGroupToState(event.portfolioId);
    }
    if (event is DeletedTradeGroup) {
      yield TradesLoading ();
      yield* _mapDeletedTradeGroupToState(event);
    }
    if (event is SelectedTrades) {
      yield TradesLoading ();
      yield* _mapSelectedTradesToState(event);
    }
    if (event is EditedTrades) {
      yield TradesLoading ();
      yield* _mapEditedTradesToState(event);
    }
    if (event is DeletedTrade) {
      yield TradesLoading ();
      yield* _mapDeletedTradeToState (event);
    }
    print ("mapEventToState: (event): " + event.toString());
  }

  Stream<TradesState> _mapDeletedTradeToState(DeletedTrade event) async* {
    try {
      await this.repository.deleteTrade([event.id]);
      yield TradesSavedOkay ();
      List<Trade> trades = await this.repository.loadAllTradesForTickerAndPortfolio(event.ticker, event.portfolioId); // get all trades by portfolio id and ticker name ordered by date desc
      yield TradesLoadedEditing (trades);
    } catch (e) {
      print ("Exception: _mapDeletedTradeToState");
      print (e);
      yield TradesFailure(message: "Can't delete this transactions!");
    }
  }

  Stream<TradesState> _mapSelectedTradesToState(SelectedTrades event) async* {
    List<Trade> trades = await this.repository.loadAllTradesForTickerAndPortfolio(event.ticker, event.portfolioId); // get all trades by portfolio id and ticker name ordered by date desc
    yield TradesLoaded (trades);
  }

  Stream<TradesState> _mapEditedTradesToState(EditedTrades event) async* {
    List<Trade> trades = await this.repository.loadAllTradesForTickerAndPortfolio(event.ticker, event.portfolioId); // get all trades by portfolio id and ticker name ordered by date desc
    yield TradesLoadedEditing (trades);
  }

  Stream<TradesState> _mapDeletedTradeGroupToState(DeletedTradeGroup event) async* {
    try {
      await this.repository.deleteAllTradesByTickerAndPortfolio(ticker: event.ticker, portfolioId: event.portfolioId);
      yield TradesSavedOkay ();
    } catch (e) {
      print ("Exception: _mapDeletedTradeGroupToState");
      print (e);
      yield TradesFailure(message: "Can't delete your transactions for this portfolio!");
    }
  }

  Stream<TradesState> _mapEditedTradeGroupToState(int portfolioId) async* {
     try {
      final trades = await this.repository.loadAllTradesForPortfolio(portfolioId);
      if (trades.length == 0) yield TradesEmpty();
      else {
        var tradeGroups = await toTickerMapFromTrades (trades);
        yield TradeGroupsLoadedEditing(tradeGroups);
      }
    } catch (e) {
      print (e);
      yield TradesFailure(message: "Can't load your transactions for this portfolio!");
    }
  }

  Stream<TradesState> _mapFinishedTransactionToState() async* {
    yield TradesFinishedEditing ();
  }
  Stream<TradesState> _mapAddedTransactionToState() async* {
    yield TradesAdding ();
  }

  Stream<TradesState> _mapPickedPortfolioToState(PickedPortfolio event) async* {
    try {
      final trades = await this.repository.loadAllTradesForPortfolio(event.portfolioId);
      if (trades.length == 0) yield TradesEmpty();
      else {
        var tradeGroups = await toTickerMapFromTrades (trades);
        yield TradeGroupsLoadSuccess(tradeGroups);
      }
    } catch (e) {
      print (e);
      yield TradesFailure(message: "Can't load your transactions for this portfolio!");
    }
  }

  Stream<TradesState> _mapTradesLoadedToState() async* {
  }

  Stream<TradesState> _mapDidTradeToState(DidTrade event) async* {
    _saveTrades([event.trade]);
    yield TradesSavedOkay ();
  }

  Future _saveTrades (List<Trade> trades)
  {
    return this.repository.saveTrades(trades);
  }
}