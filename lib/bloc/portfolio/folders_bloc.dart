import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:sma/helpers/sentry_helper.dart';

import 'package:sma/models/portfolio/folder.dart';
import 'package:sma/models/trade/trade_group.dart';
import 'package:sma/respository/portfolio/folders_storage_client.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'folders_event.dart';
part 'folders_state.dart';

class PortfolioFoldersBloc extends Bloc<PortfolioFoldersEvent, PortfolioFoldersState> {

  PortfolioFoldersBloc () : super (PortfolioFoldersInitial());

  final _foldersRepository = globalPortfolioFoldersDatabase;

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
    if (event is FinishedFolderEditing) {
      yield PortfolioFolderValidate ();
    }
    if (event is SaveFolder) {
      yield PortfolioFoldersLoading();
      try {
        await this._foldersRepository.savePortfolioFolder(model: event.model);
      } catch (e) {
        print (e);
        yield PortfolioFoldersError (message: e.toString());
      }
      yield PortfolioFolderSavedOkay(folder: event.model);
      yield PortfolioFoldersInitial();
    }
    if (event is DeleteFolder) {
      try {
        await this._foldersRepository.deletePortfolioFolder(id: event.id);
      } catch (e) {
        print (e);
        yield PortfolioFoldersError (message: e.toString());
      }
      yield PortfolioFoldersInitial();
    }
  }

  Stream<PortfolioFoldersState> _updateContent(PortfolioFoldersEvent event) async* {
    try {
      final foldersStored = await _foldersRepository.getAllPortfolioFolders();  // gets all the folders
      List<PortfolioFolderModel> updatedFolders = [];
      for (var folder in foldersStored) {
        var changes = await toTotalReturnFromPortfolioIdUpdate (folder.id);
        PortfolioFolderModel updatedFolder = PortfolioFolderModel(
          id: folder.id, userId: FirebaseAuth.instance.currentUser.uid, name: folder.name, order: folder.order, exclude: folder.exclude,
          defaultSortOption: folder.defaultSortOption,
          hideClosedPositions: folder.hideClosedPositions,
          daily: changes ['daily'], overall: changes ['overall']);
          updatedFolders.add(updatedFolder);
          _foldersRepository.savePortfolioFolder(model: updatedFolder);
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
      final foldersStored = await _foldersRepository.getAllPortfolioFolders();  // gets all the folders
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