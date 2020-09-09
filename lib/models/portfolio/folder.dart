import 'package:meta/meta.dart';
import 'package:sma/models/trade/trade_group.dart';
import 'package:uuid/uuid.dart';
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
  final String id;
  final String userId;
  final int order;
  final String name;
  final bool exclude;
  final bool hideClosedPositions;
  final SortOptions defaultSortOption;
  final FolderChange daily;
  final FolderChange overall;
  final DateTime lastUpdated = DateTime.now();

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [id, userId, order, name, exclude, hideClosedPositions, daily, overall, lastUpdated];

  PortfolioFolderModel({
    String id,
    @required this.userId,
    @required this.order,
    @required this.name,
    @required this.exclude,
    @required this.hideClosedPositions,
    @required this.defaultSortOption,
    @required this.daily,
    @required this.overall,
    lastUpdated
  }) : 
    this.id = id == null ? Uuid().v4 () : id,
    super ();

  PortfolioFolderModel.empty () :
    this.id = '',
    this.userId = '',
    this.order = -1,
    this.name = '',
    this.exclude = false,
    this.hideClosedPositions = true,
    this.defaultSortOption = SortOptions.ticker,
    this.daily = FolderChange(),
    this.overall = FolderChange();

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['userId'] = this.userId;
    data['order'] = this.order;
    data['name'] = this.name;
    data['exclude'] = this.exclude;
    data['hideClosedPositions'] = this.hideClosedPositions;
    data['defaultSortOption'] = this.defaultSortOption.toString();
    data['daily'] = this.daily.toJson();
    data['overall'] = this.overall.toJson();
    data['lastUpdated'] = this.lastUpdated.toString();
    return data;
  }

  factory PortfolioFolderModel.fromStorage(Map<String, dynamic> json) {
    SortOptions sortOption = json ['defaultSortOption'] == null ? SortOptions.ticker : SortOptions.values.firstWhere((e) => e.toString() == json ['defaultSortOption']);
    return PortfolioFolderModel(
      id: json['id'],
      userId: json['userId'],
      order: json['order'],
      name: json['name'],
      exclude: json['exclude'],
      hideClosedPositions: json['hideClosedPositions'] == null ? true : json ['hideClosedPositions'],
      defaultSortOption: sortOption,
      daily: json['daily'] == null ? FolderChange(change: 0.0, changePercentage: 0.0) : FolderChange.fromJson(json['daily']),
      overall: json['overall'] == null ? FolderChange(change: 0.0, changePercentage: 0.0) : FolderChange.fromJson(json['overall']),
      lastUpdated: json['lastUpdated'] == null ? DateTime.now() : json['lastUpdated'],
    );
  }
}