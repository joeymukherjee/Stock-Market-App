import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:sma/models/trade/trade.dart';
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
    print ("mapEventToState: (event): " + event.toString());
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
      else yield TradesLoadSuccess(trades);
    } catch (e) {
      print (e);
      yield TradesLoadFailure(message: "Can't load your transactions for this portfolio!");
    }
  }

  Stream<TradesState> _mapTradesLoadedToState() async* {
    try {
      final trades = await this.repository.loadAllTrades();
      if (trades.length == 0) yield TradesEmpty();
      else yield TradesLoadSuccess(trades);
    } catch (_) {
      yield TradesLoadFailure(message: "Can't load your transactions!");
    }
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