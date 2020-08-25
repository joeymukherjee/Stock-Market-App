part of 'watchlist_bloc.dart';

@immutable
abstract class WatchlistEvent {}

class FetchWatchlistData extends WatchlistEvent {}

class SaveProfile extends WatchlistEvent {

  final WatchListStorageModel storageModel;

  SaveProfile({
    @required this.storageModel
  });
}

class DeleteProfile extends WatchlistEvent {

  final String symbol;

  DeleteProfile({
    @required this.symbol
  });
}