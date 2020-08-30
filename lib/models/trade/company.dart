import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

@immutable
class Company extends Equatable {
  final String ticker;
  final String companyName;
  final double previousClose;
  final double lastClose;
  final DateTime lastUpdated;

  Company({
    @required this.ticker,
    @required this.companyName,
    @required this.previousClose,
    @required this.lastClose,
    @required this.lastUpdated
  });

  @override
  List<Object> get props => [ticker, companyName, previousClose, lastClose, lastUpdated];

  @override
  bool get stringify => true;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data ['ticker'] = this.ticker;
    data ['companyName'] = this.companyName;
    data ['previousClose'] = this.previousClose;
    data ['lastClose'] = this.lastClose;
    data ['lastUpdated'] = this.lastUpdated.toString();
    return data;
  } 

  factory Company.fromJson (Map<String, dynamic> json) {
    return Company(
      ticker: json ['ticker'],
      companyName: json['companyName'],
      previousClose: json ['previousClose'],
      lastClose: json ['lastClose'],
      lastUpdated: DateTime.parse(json ['lastUpdated'])
    );
  }
}