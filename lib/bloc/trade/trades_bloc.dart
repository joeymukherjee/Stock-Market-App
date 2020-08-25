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
  TradesBloc () : super ();

  @override
  TradesState get initialState => TradesInitial();

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
      yield* _mapDeletedTradeGroupToState(event);
    }
    //print ("mapEventToState: (event): " + event.toString());
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
        Map<String, TradeGroup> tradeGroups = await toTickerMapFromTrades (trades);
        yield TradeGroupLoadedEditing(tradeGroups);
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
        Map<String, TradeGroup> tradeGroups = await toTickerMapFromTrades (trades);
        yield TradesLoadSuccess(tradeGroups);
      }
    } catch (e) {
      print (e);
      yield TradesFailure(message: "Can't load your transactions for this portfolio!");
    }
  }

  Stream<TradesState> _mapTradesLoadedToState() async* {
  }

  Stream<TradesState> _mapDidTradeToState(DidTrade event) async* {
    //final List<Trade> updatedTrades = List.from((state as TradesLoadSuccess).trades)..add(event.trade);
    //yield TradesLoadSuccess (updatedTrades);
    _saveTrades([event.trade]);
    yield TradesSavedOkay ();
  }

  Future _saveTrades (List<Trade> trades)
  {
    return this.repository.saveTrades(trades);
  }
}