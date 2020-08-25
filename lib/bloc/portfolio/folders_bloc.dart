import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:sma/helpers/sentry_helper.dart';

import 'package:sma/models/portfolio/folder.dart';
import 'package:sma/models/trade/trade_group.dart';
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
    if (event is InitialLoadPortfolioFoldersData) {
      yield PortfolioFoldersLoading();
      yield* _loadContent(event);
    }
    if (event is ResyncPortfolioFoldersData) {
      yield PortfolioFoldersLoading();
      yield* _updateContent(event);
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

  Stream<PortfolioFoldersState> _updateContent(PortfolioFoldersEvent event) async* {

    try {
      final foldersStored = await _databaseRepository.fetch();  // gets all the folders
      List<PortfolioFolderModel> updatedFolders = [];
      for (var folder in foldersStored) {
        var changes = await toTotalReturnFromPortfolioId (folder.key);
        PortfolioFolderModel updatedFolder = PortfolioFolderModel(
          key: folder.key, name: folder.name, order: folder.order, exclude: folder.exclude,
          daily: changes ['daily'], overall: changes ['overall']);
          updatedFolders.add(updatedFolder);
          _databaseRepository.save(model: folder);
      }

      if (foldersStored.isNotEmpty) {
         yield PortfolioFoldersLoaded(folders: updatedFolders);
      } else {
        yield PortfolioFoldersEmpty();
      }
    } catch (e, stack) {
      yield PortfolioFoldersError(message: 'There was an unknown error. Please try again later.');
      await SentryHelper(exception: e, stackTrace: stack).report();
    }
  }

  Stream<PortfolioFoldersState> _loadContent(PortfolioFoldersEvent event) async* {
    try {
      final foldersStored = await _databaseRepository.fetch();  // gets all the folders
      if (foldersStored.isNotEmpty) {
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