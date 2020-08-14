import 'package:meta/meta.dart';

class PortfolioFolderModel {
  final String name;
  final bool exclude;

  PortfolioFolderModel({
    @required this.name,
    @required this.exclude
  });

  factory PortfolioFolderModel.fromJson(Map<String, dynamic> json) {
    return PortfolioFolderModel(
      name: json['name'],
      exclude: json['exclude'],
    );
  }
}