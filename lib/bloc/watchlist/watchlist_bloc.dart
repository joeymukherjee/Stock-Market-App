import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:sma/helpers/iex_cloud_http_helper.dart';
import 'package:sma/helpers/financial_modeling_prep_http_helper.dart';
import 'package:sma/helpers/sentry_helper.dart';

import 'package:sma/models/data_overview.dart';
import 'package:sma/models/profile/market_index.dart';
import 'package:sma/models/storage/storage.dart';

import 'package:sma/respository/watchlist/client.dart';
import 'package:sma/respository/watchlist/storage_client.dart';

part 'watchlist_event.dart';
part 'watchlist_state.dart';

class WatchlistBloc extends Bloc<WatchlistEvent, WatchlistState> {
  
  final _databaseRepository = WatchlistStorageClient();
  final _repository = WatchlistClient(IEXFetchClient());

  @override
  WatchlistState get initialState => WatchlistInitial();

  @override
  Stream<WatchlistState> mapEventToState(WatchlistEvent event) async* {

    if (event is FetchWatchlistData) {
      yield WatchlistLoading();
      yield* _loadContent();
    }

    if (event is SaveProfile) {
      yield WatchlistLoading();
      await this._databaseRepository.save(storageModel: event.storageModel);
      yield* _loadContent();
    }

    if (event is DeleteProfile) {
      yield WatchlistLoading();
      await this._databaseRepository.delete(symbol: event.symbol);
      yield* _loadContent();
    }
  }

  Stream<WatchlistState> _loadContent() async* {

    try {
      final symbolsStored = await _databaseRepository.fetch();
      final indexes = await _repository.fetchIndexes();

      if (symbolsStored.isNotEmpty) {

        final stocks =   await Future
        .wait(symbolsStored
        .map((symbol) async => await _repository.fetchStocks(symbol: symbol.symbol)));
      
        yield WatchlistLoaded(
          stocks: stocks, 
          indexes: indexes
        );

      } else {
        yield WatchlistStockEmpty(indexes: indexes);
      }
    
    } catch (e, stack) {
      yield WatchlistError(message: 'There was an unknown error. Please try again later.');
      await SentryHelper(exception: e, stackTrace: stack).report();
    }
  }
}
