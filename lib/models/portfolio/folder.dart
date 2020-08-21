import 'package:meta/meta.dart';

class FolderChange {
  final double change;
  final double changePercentage;

  FolderChange ({this.change = 0.0, this.changePercentage = 0.0});
}

class PortfolioFolderModel {
  final int order;
  final String name;
  final bool exclude;
  final FolderChange daily = FolderChange ();
  final FolderChange overall = FolderChange ();

  PortfolioFolderModel({
    @required this.order,
    @required this.name,
    @required this.exclude,
  });

  factory PortfolioFolderModel.fromJson(Map<String, dynamic> json) {
    return PortfolioFolderModel(
      order: json['order'],
      name: json['name'],
      exclude: json['exclude'],
    );
  }
}