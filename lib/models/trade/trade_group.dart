import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:sma/models/portfolio/folder.dart';
import 'package:sma/models/profile/stock_quote.dart';
import 'package:sma/models/trade/trade.dart';
import 'package:sma/helpers/fetch_client.dart';
import 'package:sma/respository/portfolio/folders_storage_client.dart';
import 'package:sma/respository/trade/trades_repo.dart';

class TradeGroup extends Equatable {
  final String ticker;
  final String companyName;
  final int portfolioId;
  final String portfolioName;
  final FolderChange daily;
  final FolderChange overall;

  TradeGroup({
    @required this.ticker,
    @required this.companyName,
    @required this.portfolioId,
    @required this.portfolioName,
    @required this.daily,
    @required this.overall
  });

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [portfolioId, ticker, companyName, portfolioName, daily, overall];

// TODO - move this somewhere
// To compute the current return, we take the total number of shares of all the trades
// (adding for purchase, subtract for sell, ??? for split, add reinvested dividend)
// and multiply this by the cost of a current share.
// We multiply the number of shares by the average cost per share,
// and subtract that from the the total return.
// Total return divided by total investment (not including dividend?) * 100 is the change percentage

// This one assumes the list of trades might have more than just the ticker we are using.
  static double computeTotalNumberOfShares (List<Trade> trades, String ticker) {
    double totalNumberOfShares = 0;
    trades.forEach((trade) {
      if (trade.ticker == ticker) {
        totalNumberOfShares = totalNumberOfShares + trade.getNumberOfShares();
      }
    });
    return totalNumberOfShares;
  }

  static double computeTotalInvestment (List<Trade> trades, String ticker) {
    double totalNumberOfShares = 0;
    trades.forEach((trade) {
      if (trade.ticker == ticker) {
        totalNumberOfShares = totalNumberOfShares + trade.getInvestment();
      }
    });
    return totalNumberOfShares;
  }

  static FolderChange computeTotalReturn (List<Trade> trades, String ticker, double currentCostPerShare) {
    double numberOfShares = computeTotalNumberOfShares (trades, ticker);
    double currentReturn = numberOfShares * currentCostPerShare;
    double totalInvestment = computeTotalInvestment (trades, ticker);
    double totalReturn = currentReturn - totalInvestment;
    double totalChangePct = totalReturn / totalInvestment * 100;
    return FolderChange (change: totalReturn, changePercentage: totalChangePct);
  }
}

Future<Map<String, FolderChange>> toTotalReturnFromPortfolioId (int portfolioId) async {
  final TradesRepository _tradesRepo = SembastTradesRepository ();
  FolderChange daily = FolderChange(change: 0.0, changePercentage: 0.0);
  FolderChange overall = FolderChange(change: 0.0, changePercentage: 0.0);
  // Get the trades by portfolio id
  Future<List<Trade>> trades = _tradesRepo.loadAllTradesForPortfolio(portfolioId);
  Future<List<TradeGroup>> tradesList = toTickerMapFromTrades(await trades);
  Future.forEach(await tradesList, (trade) => {
    daily += trade.daily,
    overall += trade.overall
  });

  return {'daily': daily, 'overall': overall};
}

Future <List<TradeGroup>> toTickerMapFromTrades (List<Trade> trades) async {
  var tickerMap = Map <String, TradeGroup> ();
  await Future.forEach (trades, ((element) async {
    if (!tickerMap.containsKey(element.ticker)) {
      StockQuote stockQuote = await globalFetchClient.getQuote(element.ticker);
      final _folderRepo = PortfolioFoldersStorageClient();
      String portfolioName = await _folderRepo.getPortfolioName(portfolioId: element.portfolioId);
      var overallReturns = TradeGroup.computeTotalReturn(trades, element.ticker, stockQuote.price);
      var yesterdayReturns = TradeGroup.computeTotalReturn(trades, element.ticker, stockQuote.previousClose.toDouble());
      var dailyReturns = overallReturns - yesterdayReturns;

      tickerMap[element.ticker] = TradeGroup (ticker: element.ticker, companyName: stockQuote.name, portfolioName: portfolioName,
                                          portfolioId: element.portfolioId,
                                          daily: dailyReturns,
                                          overall: overallReturns);
    }
  }));
  List<TradeGroup> retVal = List();
  tickerMap.forEach((key, value) => retVal.add(value));
  return retVal;
}
