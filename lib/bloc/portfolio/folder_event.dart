part of 'folder_bloc.dart';

@immutable
abstract class PortfolioFolderEvent {}

class FetchPortfolioFolderData extends PortfolioFolderEvent {}

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