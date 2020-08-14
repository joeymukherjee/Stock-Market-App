import 'package:meta/meta.dart';

class PortfolioFolderStorageModel {
  
  final String name;
  final bool exclude;

  PortfolioFolderStorageModel({
    @required this.name,
    @required this.exclude,
  });

  static List<PortfolioFolderStorageModel> convertToList(List<dynamic> items) {
    return items
    .map((item) => PortfolioFolderStorageModel.fromJson(item))
    .toList();
  }
  
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['name'] = this.name;
    data['exclude'] = this.exclude;

    return data;
  }

  factory PortfolioFolderStorageModel.fromJson(Map<String, dynamic> json) {
    return PortfolioFolderStorageModel(
      name: json['name'],
      exclude: json['exclude']
    );
  }
}