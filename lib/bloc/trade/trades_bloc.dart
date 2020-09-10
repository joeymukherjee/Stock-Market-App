import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:sma/models/trade/trade.dart';
import 'package:sma/models/trade/trade_group.dart';
import 'package:sma/models/portfolio/folder.dart';
import 'package:sma/respository/trade/trades_repo.dart';
import 'package:sma/respository/portfolio/folders_storage_client.dart';

part 'trades_event.dart';
part 'trades_state.dart';

class TradesBloc extends Bloc<TradeEvent, TradesState> {

  final TradesRepository _tradesrepository = globalTradesDatabase;
   final PortfolioFoldersRepository _foldersRepository = globalPortfolioFoldersDatabase;

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
      yield* _mapEditedTradeGroupToState(event);
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
      yield* _mapDeletedTradeToState(event);
    }
    if (event is SaveFolderOnTradeGroupPage) {
      yield TradesLoading();
      yield* _mapSaveFolderOnTradeGroupPageToState(event);
    }
    if (event is MergeMultipleTrades) {
      yield TradesLoading ();
      yield* _mapMergeMultipleTradesToState(event);
    }
    if (event is ReorderedTradeGroups) { // TODO, we should probably save the order somehow so it persists
      yield (TradeGroupsLoadSuccess(event.tradeGroups));
    }
    print ("mapEventToState: (event): " + event.toString());
  }

  Stream<TradesState> _mapSaveFolderOnTradeGroupPageToState(SaveFolderOnTradeGroupPage event) async* {
    try {
      yield await this._pickedPortfolio (event.model.id);
    } catch (e) {
      print (e);
      yield TradesFailure (message: e.toString());
    }
  }

  Stream<TradesState> _mapMergeMultipleTradesToState(MergeMultipleTrades event) async* {
    try {
      _saveTrades(event.trades);
    } catch (e) {
      print ("Exception: _mapMergeMultipleTradesToState");
      print (e);
      yield TradesFailure(message: "Can't merge these transactions!");
    }
  }

  Stream<TradesState> _mapDeletedTradeToState(DeletedTrade event) async* {
    try {
      await this._tradesrepository.deleteTrade([event.id]);
      yield TradesSavedOkay ();
      List<Trade> trades = await this._tradesrepository.loadAllTradesForTickerAndPortfolio(event.ticker, event.portfolioId); // get all trades by portfolio id and ticker name ordered by date desc
      yield TradesLoadedEditing (trades);
    } catch (e) {
      print ("Exception: _mapDeletedTradeToState");
      print (e);
      yield TradesFailure(message: "Can't delete this transactions!");
    }
  }

  Stream<TradesState> _mapSelectedTradesToState(SelectedTrades event) async* {
    final List<Trade> trades = await this._tradesrepository.loadAllTradesForTickerAndPortfolio(event.ticker, event.portfolioId); // get all trades by portfolio id and ticker name ordered by date desc
    yield TradesLoaded (trades);
  }

  Stream<TradesState> _mapEditedTradesToState(EditedTrades event) async* {
    final List<Trade> trades = await this._tradesrepository.loadAllTradesForTickerAndPortfolio(event.ticker, event.portfolioId); // get all trades by portfolio id and ticker name ordered by date desc
    yield TradesLoadedEditing (trades);
  }

  Stream<TradesState> _mapDeletedTradeGroupToState(DeletedTradeGroup event) async* {
    try {
      await this._tradesrepository.deleteAllTradesByTickerAndPortfolio(ticker: event.ticker, portfolioId: event.portfolioId);
      yield TradesSavedOkay ();
    } catch (e) {
      print ("Exception: _mapDeletedTradeGroupToState");
      print (e);
      yield TradesFailure(message: "Can't delete your transactions for this portfolio!");
    }
  }

  Stream<TradesState> _mapEditedTradeGroupToState(EditedTradeGroup event) async* {
     try {
      PortfolioFolderModel folder = await _foldersRepository.getPortfolioFolder(portfolioId: event.portfolioId);
      final trades = await this._tradesrepository.loadAllTradesForPortfolio(event.portfolioId);
      if (trades.length == 0) yield TradesEmpty();
      else {
        var tradeGroups = await toTickerMapFromTrades (trades, folder);
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
      yield await this._pickedPortfolio(event.portfolioId);
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
    return this._tradesrepository.saveTrades(trades);
  }

  Future<TradesState> _pickedPortfolio(String portfolioId) async {
    final _folderRepo = globalPortfolioFoldersDatabase;
      PortfolioFolderModel folder = await _folderRepo.getPortfolioFolder(portfolioId: portfolioId);
      final trades = await this._tradesrepository.loadAllTradesForPortfolio(portfolioId);
      if (trades == null || trades.length == 0) return TradesEmpty();
      else {
        var tradeGroups = await toTickerMapFromTrades (trades, folder);
        return TradeGroupsLoadSuccess(tradeGroups);
      }
  }
}