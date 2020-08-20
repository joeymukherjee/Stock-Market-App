import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:sma/helpers/sentry_helper.dart';

import 'package:sma/models/portfolio/folder.dart';
import 'package:sma/models/storage/portfolio_folder_storage.dart';
import 'package:sma/respository/portfolio/folder_storage_client.dart';

part 'folder_event.dart';
part 'folder_state.dart';

class PortfolioFolderBloc extends Bloc<PortfolioFolderEvent, PortfolioFolderState> {
  
  final _databaseRepository = PortfolioFolderStorageClient();

  @override
  PortfolioFolderState get initialState => PortfolioFolderInitial();

  @override
  Stream<PortfolioFolderState> mapEventToState(PortfolioFolderEvent event) async* {

    if (event is PortfolioFolderEditingEvent) {
      yield* _loadContent(event);
    }

    if (event is FetchPortfolioFolderData) {
      yield PortfolioFolderLoading();
      yield* _loadContent(event);
    }

    if (event is SaveFolder) {
      yield PortfolioFolderLoading();
      await this._databaseRepository.save(storageModel: event.storageModel);
      yield* _loadContent(event);
    }

    if (event is DeleteFolder) {
      yield PortfolioFolderLoading();
      await this._databaseRepository.delete(name: event.name);
      yield* _loadContent(event);
    }
  }

  Stream<PortfolioFolderState> _loadContent(PortfolioFolderEvent event) async* {

    try {
      final foldersStored = await _databaseRepository.fetch();
      if (foldersStored.isNotEmpty) {
        
        final folders = await Future.wait (foldersStored.map((folder) async => await _databaseRepository.fetchPortfolio (folder)));
        if (event is PortfolioFolderEditingEvent) {
          yield PortfolioFolderLoadedEditingState(folders: folders);
        } else {
          yield PortfolioFolderLoaded(folders: folders);
        }
      } else {
        yield PortfolioFolderEmpty();
      }
    } catch (e, stack) {
      yield PortfolioFolderError(message: 'There was an unknown error. Please try again later.');
      await SentryHelper(exception: e, stackTrace: stack).report();
    }
  }
}
