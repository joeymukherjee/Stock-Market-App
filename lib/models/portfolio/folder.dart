import 'package:meta/meta.dart';

class FolderChange {
  final double change;
  final double changePercentage;

  FolderChange ({this.change, this.changePercentage});
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['change'] = this.change;
    data['changePercentage'] = this.changePercentage;
    return data;
  }
  factory FolderChange.fromJson(Map<String, dynamic> json) {
    return FolderChange (changePercentage: json['changePercentage'], change: json['change']);
  }
}

class PortfolioFolderModel {
  final int key;
  final int order;
  final String name;
  final bool exclude;
  final FolderChange daily;
  final FolderChange overall;
  DateTime lastUpdated = DateTime.now();

  PortfolioFolderModel({
    @required this.key,
    @required this.order,
    @required this.name,
    @required this.exclude,
    @required this.daily,
    @required this.overall,
    lastUpdated
  });

  @override
  String toString ()
  {
    return "key: " + key.toString() + ", order: " + order.toString() + ", name: " + name + ", exclude: " + exclude.toString();
  }

  factory PortfolioFolderModel.fromStorage(int key, Map<String, dynamic> json) {
    return PortfolioFolderModel(
      key: key,
      order: json['order'],
      name: json['name'],
      exclude: json['exclude'],
      daily: json ['daily'] == null ? FolderChange(change: 0.0, changePercentage: 0.0) : FolderChange.fromJson(json['daily']),
      overall: json ['overall'] == null ? FolderChange(change: 0.0, changePercentage: 0.0) : FolderChange.fromJson(json['overall']),
      lastUpdated: json ['lastUpdated'] == null ? DateTime.now() : json['lastUpdated'],
    );
  }
}