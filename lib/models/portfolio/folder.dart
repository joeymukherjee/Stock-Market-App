import 'package:meta/meta.dart';

class FolderChange {
  final double change;
  final double changePercentage;

  FolderChange ({this.change = 0.0, this.changePercentage = 0.0});
}

class PortfolioFolderModel {
  final int key;
  final int order;
  final String name;
  final bool exclude;
  final FolderChange daily = FolderChange ();
  final FolderChange overall = FolderChange ();

  PortfolioFolderModel({
    @required this.key,
    @required this.order,
    @required this.name,
    @required this.exclude,
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
    );
  }
}