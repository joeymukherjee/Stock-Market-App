import 'package:flutter/cupertino.dart';
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
    id = id == '' ? Uuid().v4 () : id,
    super ();

  @override
  List<Object> get props => [id, portfolioId, ticker, transactionDate, type];

  @override
  bool get stringify => true;

  Map<String, dynamic> toJson()
  {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data ['id'] = this.id;
    data ['portfolioId'] = this.portfolioId;
    data ['ticker'] = this.ticker;
    data ['transactionDate'] = this.transactionDate;
    return data;
  }
  
  factory Trade.fromJson (Map<String, dynamic> json)
  {
    Trade trade;
    // trade.id = json ['id'];
    TransactionType type = json ['type'];
    switch (type) {
      case TransactionType.split : trade = Split(json ['portfolioId'], json ['ticker'], json ['transactionDate'], json ['newPrice'], json ['sharesFrom'], json ['sharesTo']); break;
      case TransactionType.purchase : trade = Common(type: TransactionType.purchase, portfolioId: json ['portfolioId'], ticker: json ['ticker'], transactionDate: json ['transactionDate'], sharesTransacted: json ['sharesTransacted'], price: json ['price'], commission: json ['commission']); break;
      case TransactionType.sell : trade = Common(type: TransactionType.purchase, portfolioId: json ['portfolioId'], ticker: json ['ticker'], transactionDate: json ['transactionDate'], sharesTransacted: json ['sharesTransacted'], price: json ['price'], commission: json ['commission']); break;
      case TransactionType.dividend : trade = Dividend(json ['portfolioId'], json ['ticker'], json ['transactionDate'], json ['sharesTransacted'], json ['price'], json ['commission'], json ['numberOfShares'], json ['amountPerShare'], json ['didReinvest'], json ['priceAtReinvest']); break;
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
  
  @override
  Map<String, dynamic> toJson()
  {
    final Map<String, dynamic> data = super.toJson();
    data ['sharesTransacted'] = this.sharesTransacted;
    data ['price'] = this.price;
    data ['commision'] = this.commission;
    return data;
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

  @override
  Map<String, dynamic> toJson()
  {
    final Map<String, dynamic> data = super.toJson();
    
    data ['amountPerShare'] = this.amountPerShare;
    data ['proceeds'] = this.proceeds;
    data ['didReinvest'] = this.didReinvest;
    data ['priceAtReinvest'] = this.priceAtReinvest;
    return data;
  }
}

class Split extends Trade {
  final double newPrice;
  final double sharesTo;
  final double sharesFrom;

  Split (int portfolioId, String ticker, DateTime transactionDate, this.newPrice, this.sharesFrom, this.sharesTo) :
    super (portfolioId: portfolioId, ticker: ticker, transactionDate: transactionDate, type: TransactionType.split);

  @override
  Map<String, dynamic> toJson()
  {
    final Map<String, dynamic> data = super.toJson();
    data ['newPrice'] = this.newPrice;
    data ['sharesTo'] = this.sharesTo;
    data ['sharesFrom'] = this.sharesFrom;
    return data;
  }
}
