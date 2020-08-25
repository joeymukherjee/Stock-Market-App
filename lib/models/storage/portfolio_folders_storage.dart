import 'package:meta/meta.dart';
import 'package:sma/models/portfolio/folder.dart';

class PortfolioFoldersStorageModel {
  
  final int order;
  final String name;
  final bool exclude;
  final FolderChange daily;
  final FolderChange overall;
  final DateTime lastUpdated;

  PortfolioFoldersStorageModel({
    @required this.order,
    @required this.name,
    @required this.exclude,
    @required this.daily,
    @required this.overall,
    @required this.lastUpdated
  });

  static List<PortfolioFoldersStorageModel> convertToList(List<dynamic> items) {
    return items
    .map((item) => PortfolioFoldersStorageModel.fromJson(item))
    .toList();
  }
  
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['order'] = this.order;
    data['name'] = this.name;
    data['exclude'] = this.exclude;
    data['daily'] = this.daily.toJson();
    data['overall'] = this.overall.toJson();
    data['lastUpdated'] = this.lastUpdated.toString();
    return data;
  }

  factory PortfolioFoldersStorageModel.fromJson(Map<String, dynamic> json) {
    return PortfolioFoldersStorageModel(
      order: json ['order'],
      name: json['name'],
      exclude: json['exclude'],
      daily: json['daily'],
      overall: json['overall'],
      lastUpdated: DateTime.parse(json ['lastUpdated'])
    );
  }
}