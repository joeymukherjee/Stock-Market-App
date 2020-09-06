part of 'folders_bloc.dart';

@immutable
abstract class PortfolioFoldersEvent {}

class PortfolioFoldersEditingEvent extends PortfolioFoldersEvent {}

class InitialLoadPortfolioFoldersData extends PortfolioFoldersEvent {
  InitialLoadPortfolioFoldersData ()
  {
    print ("InitialLoadPortfolioFoldersData");
  }
}

class ResyncPortfolioFoldersData extends PortfolioFoldersEvent {
  ResyncPortfolioFoldersData ()
  {
    print ("ResyncPortfolioFoldersData");
  }
}

class SaveFolder extends PortfolioFoldersEvent {

  final PortfolioFolderModel model;

  SaveFolder({
    @required this.model
  });
}

class DeleteFolder extends PortfolioFoldersEvent {

  final String id;

  DeleteFolder({
    @required this.id
  });
}

class FinishedFolderEditing extends PortfolioFoldersEvent {}