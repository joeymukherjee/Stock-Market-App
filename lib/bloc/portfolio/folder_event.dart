part of 'folder_bloc.dart';

@immutable
abstract class PortfolioFolderEvent {}

class PortfolioFolderEditingEvent extends PortfolioFolderEvent {}

class FetchPortfolioFolderData extends PortfolioFolderEvent {
  FetchPortfolioFolderData ()
  {
    print ("FetchPortfolioFolderData");
  }
}
class SaveFolder extends PortfolioFolderEvent {

  final PortfolioFolderStorageModel storageModel;

  SaveFolder({
    @required this.storageModel
  });
}

class DeleteFolder extends PortfolioFolderEvent {

  final String name;

  DeleteFolder({
    @required this.name
  });
}