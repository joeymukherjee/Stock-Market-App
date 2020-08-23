part of 'folders_bloc.dart';

@immutable
abstract class PortfolioFoldersEvent {}

class PortfolioFoldersEditingEvent extends PortfolioFoldersEvent {}

class FetchPortfolioFoldersData extends PortfolioFoldersEvent {
  FetchPortfolioFoldersData ()
  {
    print ("FetchPortfolioFoldersData");
  }
}

class SaveFolder extends PortfolioFoldersEvent {

  final PortfolioFolderModel model;

  SaveFolder({
    @required this.model
  });
}

class DeleteFolder extends PortfolioFoldersEvent {

  final String name;

  DeleteFolder({
    @required this.name
  });
}