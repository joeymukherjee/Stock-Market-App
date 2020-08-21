import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:sma/helpers/sentry_helper.dart';

import 'package:sma/models/portfolio/folder.dart';
import 'package:sma/respository/portfolio/folders_storage_client.dart';

part 'folders_event.dart';
part 'folders_state.dart';

class PortfolioFoldersBloc extends Bloc<PortfolioFoldersEvent, PortfolioFoldersState> {
  
  final _databaseRepository = PortfolioFoldersStorageClient();

  @override
  PortfolioFoldersState get initialState => PortfolioFoldersInitial();

  @override
  Stream<PortfolioFoldersState> mapEventToState(PortfolioFoldersEvent event) async* {

    if (event is PortfolioFoldersEditingEvent) {
      yield* _loadContent(event);
    }

    if (event is FetchPortfolioFoldersData) {
      yield PortfolioFoldersLoading();
      yield* _loadContent(event);
    }

    if (event is SaveFolder) {
      yield PortfolioFoldersLoading();
      await this._databaseRepository.save(model: event.model);
      yield* _loadContent(event);
    }

    if (event is DeleteFolder) {
      yield PortfolioFoldersLoading();
      await this._databaseRepository.delete(name: event.name);
      yield* _loadContent(event);
    }
  }

  Stream<PortfolioFoldersState> _loadContent(PortfolioFoldersEvent event) async* {

    try {
      final foldersStored = await _databaseRepository.fetch();  // gets all the folders
      print (foldersStored);
      if (foldersStored.isNotEmpty) {
        //final folders = await Future.wait (foldersStored.map((folder) async => await _databaseRepository.fetchPortfolio (folder)));
        if (event is PortfolioFoldersEditingEvent) {
          yield PortfolioFoldersLoadedEditingState(folders: foldersStored);
        } else {
          yield PortfolioFoldersLoaded(folders: foldersStored);
        }
      } else {
        yield PortfolioFoldersEmpty();
      }
    } catch (e, stack) {
      yield PortfolioFoldersError(message: 'There was an unknown error. Please try again later.');
      await SentryHelper(exception: e, stackTrace: stack).report();
    }
  }
}