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
  //final _repository = PortfolioFolderClient();

  @override
  PortfolioFolderState get initialState => PortfolioFolderInitial();

  @override
  Stream<PortfolioFolderState> mapEventToState(PortfolioFolderEvent event) async* {

    if (event is FetchPortfolioFolderData) {
      yield PortfolioFolderLoading();
      yield* _loadContent();
    }

    if (event is SaveFolder) {
      yield PortfolioFolderLoading();
      await this._databaseRepository.save(storageModel: event.storageModel);
      yield* _loadContent();
    }

    if (event is DeleteFolder) {
      yield PortfolioFolderLoading();
      await this._databaseRepository.delete(name: event.name);
      yield* _loadContent();
    }
  }

  Stream<PortfolioFolderState> _loadContent() async* {

    try {
      final foldersStored = await _databaseRepository.fetch();
      // final indexes = await _repository.fetchIndexes();
      if (foldersStored.isNotEmpty) {
        
        final folders = await Future.wait (foldersStored.map((folder) async => await _databaseRepository.fetchPortfolio (folder)));
        yield PortfolioFolderLoaded(folders: folders);
        
        print ("loading folders");

      } else {
        yield PortfolioFolderEmpty();
      }
    } catch (e, stack) {
      yield PortfolioFolderError(message: 'There was an unknown error. Please try again later.');
      await SentryHelper(exception: e, stackTrace: stack).report();
    }
  }
}
