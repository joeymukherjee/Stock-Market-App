import 'package:meta/meta.dart';

class PortfolioFolderModel {
  final String name;
  final bool exclude;
  final double change;
  final double changePercentage;

  PortfolioFolderModel({
    @required this.name,
    @required this.exclude,
    this.change = 0.0,
    this.changePercentage = 0.0
  });

  factory PortfolioFolderModel.fromJson(Map<String, dynamic> json) {
    return PortfolioFolderModel(
      name: json['name'],
      exclude: json['exclude'],
    );
  }
}