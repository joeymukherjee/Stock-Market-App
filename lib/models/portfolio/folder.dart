import 'package:meta/meta.dart';

class FolderChange {
  final double change;
  final double changePercentage;

  FolderChange ({this.change = 0.0, this.changePercentage = 0.0});
}

class PortfolioFolderModel {
  final String name;
  final bool exclude;
  final FolderChange daily = FolderChange ();
  final FolderChange overall = FolderChange ();

  PortfolioFolderModel({
    @required this.name,
    @required this.exclude,
  });

  factory PortfolioFolderModel.fromJson(Map<String, dynamic> json) {
    return PortfolioFolderModel(
      name: json['name'],
      exclude: json['exclude'],
    );
  }
}