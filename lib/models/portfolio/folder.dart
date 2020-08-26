import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

class FolderChange extends Equatable {
  final double change;
  final double changePercentage;

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [change, changePercentage];

  FolderChange operator - (FolderChange other) => FolderChange (
    changePercentage: (changePercentage - other.changePercentage),
    change: (change - other.change)
  );

  FolderChange operator + (FolderChange other) => FolderChange (
    changePercentage: (changePercentage + other.changePercentage),
    change: (change + other.change)
  );

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

class PortfolioFolderModel extends Equatable {
  final int key;
  final int order;
  final String name;
  final bool exclude;
  final FolderChange daily;
  final FolderChange overall;
  final DateTime lastUpdated = DateTime.now();

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [key, order, name, exclude, daily, overall, lastUpdated];

  PortfolioFolderModel({
    @required this.key,
    @required this.order,
    @required this.name,
    @required this.exclude,
    @required this.daily,
    @required this.overall,
    lastUpdated
  });

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