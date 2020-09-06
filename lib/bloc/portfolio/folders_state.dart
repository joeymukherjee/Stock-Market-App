part of 'folders_bloc.dart';

@immutable
abstract class PortfolioFoldersState {}

class PortfolioFoldersInitial extends PortfolioFoldersState {}

class PortfolioFoldersError extends PortfolioFoldersState {

  final String message;

  PortfolioFoldersError({
    @required this.message
  });
}

class PortfolioFoldersEditingState extends PortfolioFoldersState {}
class PortfolioFoldersLoadedEditingState extends PortfolioFoldersState {

  final List<PortfolioFolderModel> folders;

  PortfolioFoldersLoadedEditingState({
    @required this.folders,
  });
}

class PortfolioFoldersEmpty extends PortfolioFoldersState {}

class PortfolioFoldersLoading extends PortfolioFoldersState {}

class PortfolioFoldersLoaded extends PortfolioFoldersState {

  final List<PortfolioFolderModel> folders;

  PortfolioFoldersLoaded({
    @required this.folders,
  });
}

class PortfolioFolderValidate extends PortfolioFoldersState {}
class PortfolioFolderSavedOkay extends PortfolioFoldersState {}