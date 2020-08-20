import 'package:meta/meta.dart';

class PortfolioFoldersStorageModel {
  
  final String name;
  final bool exclude;

  PortfolioFoldersStorageModel({
    @required this.name,
    @required this.exclude,
  });

  static List<PortfolioFoldersStorageModel> convertToList(List<dynamic> items) {
    return items
    .map((item) => PortfolioFoldersStorageModel.fromJson(item))
    .toList();
  }
  
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['name'] = this.name;
    data['exclude'] = this.exclude;

    return data;
  }

  factory PortfolioFoldersStorageModel.fromJson(Map<String, dynamic> json) {
    return PortfolioFoldersStorageModel(
      name: json['name'],
      exclude: json['exclude']
    );
  }
}