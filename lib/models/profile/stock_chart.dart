import 'package:meta/meta.dart';

class StockChart {
  final String date;
  final double close;
  final String label;

  StockChart({
    @required this.date,
    @required this.close,
    @required this.label
  });

  static List<StockChart> toList(List<dynamic> items) {
    var retVal = items
    .map((item) => StockChart.fromJson(item))
    .toList();
    retVal.removeWhere((element) => element == null);
    return (retVal);
  } 

  factory StockChart.fromJson(Map<dynamic, dynamic> json) {
    if (json ['close'] == null) return (null);
    return StockChart(
      date: json.containsKey ('minute') ? json['date'] + ' ' + json ['minute'] : json ['date'],
      close: json['close'].toDouble (), // This has to stay converting or the plot doesn't work?
      label: json['label'],
    );
  }

}
