part of 'watchlist_bloc.dart';

@immutable
abstract class WatchlistState {}

class WatchlistInitial extends WatchlistState {}

class WatchlistError extends WatchlistState {

  final String message;

  WatchlistError({
    @required this.message
  });
}

class WatchlistStockEmpty extends WatchlistState {

  final List<MarketIndexModel> indexes;

  WatchlistStockEmpty({
    @required this.indexes,
  });
}

class WatchlistLoading extends WatchlistState {}

class WatchlistLoaded extends WatchlistState {

  final List<StockOverviewModel> stocks;
  final List<MarketIndexModel> indexes;

  WatchlistLoaded({
    @required this.stocks,
    @required this.indexes,
  });
}
