import 'dart:collection';

import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:sma/models/portfolio/folder.dart';
import 'package:sma/models/profile/stock_quote.dart';
import 'package:sma/models/trade/trade.dart';
import 'package:sma/models/trade/company.dart';
import 'package:sma/helpers/fetch_client.dart';
import 'package:sma/respository/portfolio/folders_storage_client.dart';
import 'package:sma/respository/trade/trades_repo.dart';
import 'package:sma/respository/trade/companies_repo.dart';

class TradeGroup extends Equatable {
  final String ticker;
  final String companyName;
  final PortfolioFolderModel folder;
  final double totalNumberOfShares;
  final double totalEquity;
  final FolderChange daily;
  final FolderChange overall;

  TradeGroup({
    @required this.ticker,
    @required this.companyName,
    @required this.folder,
    @required this.totalNumberOfShares,
    @required this.totalEquity,
    @required this.daily,
    @required this.overall
  });

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [ticker, companyName, folder, totalNumberOfShares, totalEquity, daily, overall];

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
        if (trade.type == TransactionType.split) {
          Split split = trade as Split;
          totalNumberOfShares = totalNumberOfShares * split.sharesTo / split.sharesFrom;
        }
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
    double totalChangePct = totalReturn / totalInvestment;
    return FolderChange (change: totalReturn, changePercentage: totalChangePct);
  }
}

enum SortOptions {none, order, ticker, equity, dailyChange, dailyChangePercentage, overallChange, overallChangePercentage}

Future<Map<String, FolderChange>> toTotalReturnFromPortfolioIdUpdate (String portfolioId, SortOptions sortOptions) async {
  final TradesRepository _tradesRepo = globalTradesDatabase;
  FolderChange daily = FolderChange(change: 0.0, changePercentage: 0.0);
  FolderChange overall = FolderChange(change: 0.0, changePercentage: 0.0);
  // Get the trades by portfolio id
  Future<List<Trade>> trades = _tradesRepo.loadAllTradesForPortfolio(portfolioId);
  updateCompanies(await trades);
  Future<List<TradeGroup>> tradesList = toTickerMapFromTrades (await trades, sortOptions);
  Future.forEach(await tradesList, (trade) => {
    daily += trade.daily,
    overall += trade.overall
  });

  return {'daily': daily, 'overall': overall};
}

Future<TradeGroup> getTradeGroup (String ticker, String portfolioId, Company company, List<Trade> trades) async
{
  final _folderRepo = globalPortfolioFoldersDatabase;
  PortfolioFolderModel folder = await _folderRepo.getPortfolioFolder(portfolioId: portfolioId);
  final _companiesRepo = LocalCompaniesRepository ();

  if (company == null) {
    StockQuote stockQuote = await globalFetchClient.getQuote(ticker);
    company = Company (
      ticker: ticker,
      companyName: stockQuote.name,
      previousClose: stockQuote.previousClose == null ? 0.0 : stockQuote.previousClose.toDouble(),
      lastClose: stockQuote.previousClose == null ? 0.0 : stockQuote.price,
      lastUpdated: DateTime.now()
    );
    _companiesRepo.saveCompanies([company]);
  }
  double numberOfShares = double.parse (TradeGroup.computeTotalNumberOfShares(trades, ticker).toStringAsFixed(3));
  double equity = TradeGroup.computeTotalInvestment(trades, ticker);
  var overallReturns = TradeGroup.computeTotalReturn(trades, ticker, company.lastClose);
  var yesterdayReturns = TradeGroup.computeTotalReturn(trades, ticker, company.previousClose);
  var dailyReturns = overallReturns - yesterdayReturns;
  return TradeGroup (ticker: ticker,
                    companyName: company.companyName,
                    folder: folder,
                    totalNumberOfShares: numberOfShares,
                    totalEquity: equity,
                    daily: dailyReturns,
                    overall: overallReturns);
}
// This gets the ticker map based on previously saved data

Future <List<TradeGroup>> toTickerMapFromTrades (List<Trade> trades, SortOptions sortOptions) async {
  var tickerMap = Map <String, TradeGroup> ();
  final _companiesRepo = LocalCompaniesRepository ();
  await Future.forEach (trades, ((trade) async {
    if (!tickerMap.containsKey(trade.ticker)) {
      Company company = await _companiesRepo.loadCompany (trade.ticker);
      tickerMap[trade.ticker] = await getTradeGroup (trade.ticker, trade.portfolioId, company, trades);
    }
  }));

  SplayTreeMap <dynamic, TradeGroup> sortedMap = SplayTreeMap (
    (dynamic key1, dynamic key2) {
      return key1 is num ? ((key1 as double).compareTo(key2 as double)) : key1.compareTo (key2);
    }
  );

  if (sortOptions == SortOptions.none) {
    // This does not ignore our closed positions and applies no sorting!!
    List<TradeGroup> retVal = List();
    tickerMap.forEach((key, value) { retVal.add (value); });
    return retVal;
  } else {
    tickerMap.forEach((key, value) {
        if (value.totalNumberOfShares != 0 || !value.folder.hideClosedPositions) {
          dynamic key;
          switch (sortOptions) {
            case SortOptions.none : break; // NEVER REACHED!
            case SortOptions.order : key = value.ticker; break; // TODO - we don't have order saved?
            case SortOptions.ticker : key = value.ticker; break;
            case SortOptions.equity : key = value.totalEquity + value.overall.change; break;
            case SortOptions.dailyChange : key = value.daily.change; break;
            case SortOptions.dailyChangePercentage : key = value.daily.changePercentage; break;
            case SortOptions.overallChange : key = value.overall.change; break;
            case SortOptions.overallChangePercentage : key = value.overall.changePercentage; break;
          }
          sortedMap [key] = (value);
        }
      }
    );
    List<TradeGroup> retVal = List();
    sortedMap.forEach((key, value) { retVal.add (value); });
    return retVal;
  }
}

// update all the companies in a list of trades
void updateCompanies (List<Trade> trades) async {
  var doneList = List <String> ();
  final _companiesRepo = LocalCompaniesRepository ();
  await Future.forEach (trades, ((trade) async {
    if (!doneList.contains(trade.ticker)) {
      StockQuote stockQuote = await globalFetchClient.getQuote(trade.ticker);
      Company company = Company (
        ticker: trade.ticker,
        companyName: stockQuote.name,
        previousClose: stockQuote.previousClose == null ? 0.0 : stockQuote.previousClose.toDouble(),
        lastClose: stockQuote.previousClose == null ? 0.0 : stockQuote.price,
        lastUpdated: DateTime.now()
      );
      _companiesRepo.saveCompanies([company]);
    }
  }));
}
