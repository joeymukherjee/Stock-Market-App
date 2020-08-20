part of 'folder_bloc.dart';

@immutable
abstract class PortfolioFolderState {}

class PortfolioFolderInitial extends PortfolioFolderState {}

class PortfolioFolderError extends PortfolioFolderState {

  final String message;

  PortfolioFolderError({
    @required this.message
  });
}

class PortfolioFolderEditingState extends PortfolioFolderState {}
class PortfolioFolderLoadedEditingState extends PortfolioFolderState {

  final List<PortfolioFolderModel> folders;

  PortfolioFolderLoadedEditingState({
    @required this.folders,
  });
}

class PortfolioFolderEmpty extends PortfolioFolderState {}

class PortfolioFolderLoading extends PortfolioFolderState {}

class PortfolioFolderLoaded extends PortfolioFolderState {

  final List<PortfolioFolderModel> folders;

  PortfolioFolderLoaded({
    @required this.folders,
  });
}
