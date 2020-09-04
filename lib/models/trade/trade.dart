import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';
import 'package:equatable/equatable.dart';

enum TransactionType {purchase, sell, dividend, split}

@immutable
abstract class Trade extends Equatable {
  final String id;
  final int portfolioId;
  final String ticker;
  final DateTime transactionDate;
  final TransactionType type;

  Trade ({
    String id,
    @required this.portfolioId,
    @required this.ticker,
    @required this.transactionDate,
    @required this.type,
  }) :
    id = id == null ? Uuid().v4 () : id,
    super ();

  Trade.withId ({
    @required String id,
    @required this.portfolioId,
    @required this.ticker,
    @required this.transactionDate,
    @required this.type,
  }):
    this.id = id == null ? Uuid().v4 () : id,
    super ();

  double getTotalReturn ();
  double getNumberOfShares ();
  double getInvestment ();

  @override
  List<Object> get props => [id, portfolioId, ticker, transactionDate, type];

  @override
  bool get stringify => true;

  Map<String, dynamic> toJson()
  {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data ['id'] = this.id;
    data ['portfolioId'] = this.portfolioId.toString();
    data ['ticker'] = this.ticker;
    data ['transactionDate'] = this.transactionDate.toString();
    data ['type'] = this.type.toString();
    return data;
  }

  factory Trade.fromJson (Map<String, dynamic> json)
  {
    Trade trade;
    TransactionType type = TransactionType.values.firstWhere((e) => e.toString() == json ['type']);
    switch (type) {
      case TransactionType.split : trade = Split.withId(
            id: json ['id'],
            portfolioId: int.parse(json ['portfolioId']),
            ticker: json ['ticker'],
            transactionDate: DateTime.parse(json ['transactionDate']),
            sharesFrom: double.parse(json ['sharesFrom']),
            sharesTo: double.parse(json ['sharesTo']));
        break;
      case TransactionType.purchase : trade = Common.withId(
            id: json ['id'],
            type: TransactionType.purchase,
            portfolioId: int.parse(json ['portfolioId']),
            ticker: json ['ticker'],
            transactionDate: DateTime.parse(json ['transactionDate']),
            sharesTransacted: double.parse (json ['sharesTransacted']),
            price: double.parse(json ['price']),
            commission: double.parse(json ['commission']));
        break;
      case TransactionType.sell : trade = Common.withId(
            id: json ['id'], type: TransactionType.sell,
            portfolioId: int.parse(json ['portfolioId']),
            ticker: json ['ticker'],
            transactionDate: DateTime.parse(json ['transactionDate']),
            sharesTransacted: double.parse(json ['sharesTransacted']),
            price: double.parse(json ['price']),
            commission: double.parse(json ['commission']));
        break;
      case TransactionType.dividend : trade = Dividend.withId(
            id: json ['id'],
            portfolioId: int.parse(json ['portfolioId']),
            ticker: json ['ticker'],
            transactionDate: DateTime.parse(json ['transactionDate']),
            sharesTransacted: double.parse(json ['sharesTransacted']),
            price: double.parse(json ['price']),
            commission: double.parse(json ['commission']),
            numberOfShares: json ['numberOfShares'] == null ? 0.0 : double.parse(json ['numberOfShares']),
            amountPerShare: double.parse(json['amountPerShare']),
            didReinvest: json ['didReinvest'] == 'true' ? true : false);
        break;
    }
    return trade;
  }
}

// Common is used for buying/selling
class Common extends Trade {
  final double sharesTransacted;
  final double price;
  final double commission;
  final double paid;

  Common ({
    @required int portfolioId,
    @required String ticker,
    @required DateTime transactionDate,
    @required TransactionType type,
    @required this.sharesTransacted,
    @required this.price,
    @required this.commission}) :
    this.paid = price * sharesTransacted - commission,
    super (portfolioId: portfolioId, ticker: ticker, transactionDate: transactionDate, type: type);

  Common.withId ({
    @required String id,
    @required int portfolioId,
    @required String ticker,
    @required DateTime transactionDate,
    @required TransactionType type,
    @required this.sharesTransacted,
    @required this.price,
    @required this.commission}) :
    this.paid = price * sharesTransacted - commission,
    super (id: id, portfolioId: portfolioId, ticker: ticker, transactionDate: transactionDate, type: type);

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [id, portfolioId, ticker, type, sharesTransacted, price, commission, paid];

  @override
  Map<String, dynamic> toJson()
  {
    final Map<String, dynamic> data = super.toJson();
    data ['sharesTransacted'] = this.sharesTransacted.toString();
    data ['price'] = this.price.toString();
    data ['commission'] = this.commission.toString();
    return data;
  }

  double getTotalReturn () {
    return this.price * this.sharesTransacted - this.commission;
  }

  double getNumberOfShares () {
    return this.type == TransactionType.purchase ? this.sharesTransacted : -this.sharesTransacted;
  }

  double getInvestment () {
    return this.type == TransactionType.purchase ? this.paid : -this.paid;
  }
}

class Dividend extends Common {
  final double numberOfShares;
  final double amountPerShare;
  final double proceeds;
  final bool didReinvest;

  Dividend (int portfolioId, String ticker, DateTime transactionDate, double sharesTransacted, double price, double commission, this.numberOfShares, this.amountPerShare, this.didReinvest) :
    this.proceeds = amountPerShare * numberOfShares,
    super (portfolioId: portfolioId, ticker: ticker, transactionDate: transactionDate, type: TransactionType.dividend, sharesTransacted: sharesTransacted, price: price, commission: commission);

  Dividend.withId ({
    @required String id,
    @required int portfolioId,
    @required String ticker,
    @required DateTime transactionDate,
    @required double sharesTransacted,
    @required double price,
    @required double commission,
    @required this.numberOfShares,
    @required this.amountPerShare,
    @required this.didReinvest}) :
    this.proceeds = amountPerShare * numberOfShares,
    super.withId (id: id, portfolioId: portfolioId, ticker: ticker, transactionDate: transactionDate, type: TransactionType.dividend, sharesTransacted: sharesTransacted, price: price, commission: commission);

  @override
  Map<String, dynamic> toJson()
  {
    final Map<String, dynamic> data = super.toJson();

    data ['numberOfShares'] = this.numberOfShares.toString();
    data ['amountPerShare'] = this.amountPerShare.toString();
    data ['proceeds'] = this.proceeds.toString();
    data ['didReinvest'] = this.didReinvest.toString();
    return data;
  }

  double getTotalReturn () {
    return -this.proceeds;
  }

  double getNumberOfShares () {
    return didReinvest ? this.sharesTransacted : 0.0;
  }

  double getInvestment () {
    return -this.proceeds; // we received this money so it is negative!
  }
}

class Split extends Trade {
  final double sharesTo;
  final double sharesFrom;

  Split (int portfolioId, String ticker, DateTime transactionDate, this.sharesFrom, this.sharesTo) :
    super (portfolioId: portfolioId, ticker: ticker, transactionDate: transactionDate, type: TransactionType.split);

  Split.withId ({
    @required String id,
    @required int portfolioId,
    @required String ticker,
    @required DateTime transactionDate,
    @required this.sharesFrom,
    @required this.sharesTo}) :
    super.withId (id: id, portfolioId: portfolioId, ticker: ticker, transactionDate: transactionDate, type: TransactionType.split);

  @override
  Map<String, dynamic> toJson()
  {
    final Map<String, dynamic> data = super.toJson();
    data ['sharesTo'] = this.sharesTo.toString();
    data ['sharesFrom'] = this.sharesFrom.toString();
    return data;
  }

  double getTotalReturn () {
     return 0.0;
  }

  double getNumberOfShares () {
    return 0.0;
  }

  double getInvestment () {
    return 0.0;
  }
}
