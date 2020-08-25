import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:sma/models/profile/stock_quote.dart';
import 'package:sma/models/trade/trade.dart';
import 'package:sma/helpers/fetch_client.dart';
import 'package:sma/respository/portfolio/folders_storage_client.dart';

class TradeGroup extends Equatable {
  final String ticker;
  final String companyName;
  final int portfolioId;
  final String portfolioName;
  final double totalReturn;
  final double changePercentage;

  TradeGroup({
    @required this.ticker,
    @required this.companyName,
    @required this.portfolioId,
    @required this.portfolioName,
    @required this.totalReturn,
    @required this.changePercentage
  });

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [portfolioId, ticker, companyName, portfolioName, totalReturn, changePercentage];

  static double computeTotalReturn (List<Trade> trades, String ticker) {
    double totalReturn = 0.0;
    trades.forEach((trade) { 
      if (trade.ticker == ticker) {
        totalReturn = totalReturn + trade.getTotalReturn();
      }
    });
    return totalReturn;
  }

  TradeGroup.fromTrades (List<Trade> trades, this.portfolioName, StockQuote stockQuote) : 
    this.ticker = trades [0].ticker,
    this.portfolioId = trades [0].portfolioId,
    this.companyName = stockQuote.name,
    this.totalReturn = 83123.21,
    this.changePercentage = 9.9
   {
    //return TradeGroup (ticker: ticker, companyName: companyName, portfolioId: portfolioId, portfolioName: portfolioName, totalReturn: totalReturn, changePercentage: changePercentage);
   }
}

Future <Map<String, TradeGroup>> toTickerMapFromTrades (List<Trade> trades) async {
  // Map<String, TradeGroup> retVal;
  var retVal = Map <String, TradeGroup> ();
  await Future.forEach (trades, ((element) async {
    if (!retVal.containsKey(element.ticker)) {
      
      StockQuote stockQuote = await globalFetchClient.getQuote(element.ticker);
      final _folderRepo = PortfolioFoldersStorageClient();
      String portfolioName = await _folderRepo.getPortfolioName(portfolioId: element.portfolioId);
      retVal[element.ticker] = TradeGroup (ticker: element.ticker, companyName: stockQuote.name, portfolioName: portfolioName,
                                          portfolioId: element.portfolioId, totalReturn: TradeGroup.computeTotalReturn(trades, element.ticker),
                                          changePercentage: 9.9);
    }
  }));
  return retVal;
}
