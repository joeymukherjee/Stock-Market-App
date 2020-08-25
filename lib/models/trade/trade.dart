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
 //   @required this.id,
    String id,
    @required this.portfolioId, 
    @required this.ticker, 
    @required this.transactionDate, 
    @required this.type, 
  }) : 
    id = id == null ? Uuid().v4 () : id,
    super ();

  Trade.withId ({
    @required this.id,
    @required this.portfolioId,
    @required this.ticker,
    @required this.transactionDate,
    @required this.type,
  });

  double getTotalReturn ();

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
      case TransactionType.split : trade = Split.withId(id: json ['id'], portfolioId: json ['portfolioId'], ticker: json ['ticker'], transactionDate: json ['transactionDate'], sharesTransacted: json ['sharesTransacted'], price: json ['price'], sharesFrom: json ['sharesFrom'], sharesTo: json ['sharesTo']); break;
      case TransactionType.purchase : trade = Common.withId(id: json ['id'], type: TransactionType.purchase, portfolioId: int.parse(json ['portfolioId']), ticker: json ['ticker'], transactionDate: DateTime.parse(json ['transactionDate']), sharesTransacted: double.parse (json ['sharesTransacted']), price: double.parse(json ['price']), commission: double.parse(json ['commission'])); break;
      case TransactionType.sell : trade = Common.withId(id: json ['id'], type: TransactionType.sell, portfolioId: json ['portfolioId'], ticker: json ['ticker'], transactionDate: json ['transactionDate'], sharesTransacted: json ['sharesTransacted'], price: json ['price'], commission: json ['commission']); break;
      case TransactionType.dividend : trade = Dividend.withId(id: json ['id'], portfolioId: json ['portfolioId'], ticker: json ['ticker'], transactionDate: json ['transactionDate'], sharesTransacted: json ['sharesTransacted'], price: json ['price'], commission: json ['commission'], numberOfShares: json ['numberOfShares'], amountPerShare: json ['amountPerShare'], didReinvest: json ['didReinvest'], priceAtReinvest: json ['priceAtReinvest']); break;
    }
    return trade;
  }
}

// Common is used for buying/selling - sharesTransacted will be negative
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
}

class Dividend extends Common {
  final double amountPerShare;
  final double proceeds;
  final bool didReinvest;
  final double priceAtReinvest;

  Dividend (int portfolioId, String ticker, DateTime transactionDate, double sharesTransacted, double price, double commission, double numberOfShares, this.amountPerShare, this.didReinvest, this.priceAtReinvest) :
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
    @required double numberOfShares,
    @required this.amountPerShare,
    @required this.didReinvest,
    @required this.priceAtReinvest}) :
    this.proceeds = amountPerShare * numberOfShares,
    super.withId (id: id, portfolioId: portfolioId, ticker: ticker, transactionDate: transactionDate, type: TransactionType.dividend, sharesTransacted: sharesTransacted, price: price, commission: commission);

  @override
  Map<String, dynamic> toJson()
  {
    final Map<String, dynamic> data = super.toJson();
    
    data ['amountPerShare'] = this.amountPerShare.toString();
    data ['proceeds'] = this.proceeds.toString();
    data ['didReinvest'] = this.didReinvest.toString();
    data ['priceAtReinvest'] = this.priceAtReinvest.toString();
    return data;
  }

  double getTotalReturn () {
    return 0.0; // TODO - need to figure this out... this.numberOfShares * this.sharesTransacted - this.commission;
  }
}

class Split extends Trade {
  final double price;
  final double sharesTo;
  final double sharesFrom;

  Split (int portfolioId, String ticker, DateTime transactionDate, this.price, this.sharesFrom, this.sharesTo) :
    super (portfolioId: portfolioId, ticker: ticker, transactionDate: transactionDate, type: TransactionType.split);

  Split.withId ({
    @required String id,
    @required int portfolioId,
    @required String ticker,
    @required DateTime transactionDate,
    @required double sharesTransacted,
    @required this.price,
    @required this.sharesFrom,
    @required this.sharesTo}) :
    super.withId (id: id, portfolioId: portfolioId, ticker: ticker, transactionDate: transactionDate, type: TransactionType.split);

  @override
  Map<String, dynamic> toJson()
  {
    final Map<String, String> data = super.toJson();
    data ['price'] = this.price.toString();
    data ['sharesTo'] = this.sharesTo.toString();
    data ['sharesFrom'] = this.sharesFrom.toString();
    return data;
  }

  double getTotalReturn () {
    return 0.0; // TODO - need to figure this out... this.numberOfShares * this.sharesTransacted - this.commission;
  }
}
