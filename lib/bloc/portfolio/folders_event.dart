part of 'folder_bloc.dart';

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

  final PortfolioFoldersStorageModel storageModel;

  SaveFolder({
    @required this.storageModel
  });
}

class DeleteFolder extends PortfolioFoldersEvent {

  final String name;

  DeleteFolder({
    @required this.name
  });
}