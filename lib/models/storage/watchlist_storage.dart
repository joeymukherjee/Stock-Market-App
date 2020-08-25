import 'package:meta/meta.dart';

class WatchListStorageModel {
  
  final String symbol;
  final String companyName;

  WatchListStorageModel({
    @required this.symbol,
    @required this.companyName,
  });

  static List<WatchListStorageModel> convertToList(List<dynamic> items) {
    return items
    .map((item) => WatchListStorageModel.fromJson(item))
    .toList();
  }
  
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['symbol'] = this.symbol;
    data['companyName'] = this.companyName;

    return data;
  }

  factory WatchListStorageModel.fromJson(Map<String, dynamic> json) {
    return WatchListStorageModel(
      symbol: json['symbol'],
      companyName: json['companyName'],
    );
  }
}