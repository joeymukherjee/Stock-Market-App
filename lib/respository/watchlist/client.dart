import 'package:sma/helpers/fetch_client.dart';
import 'package:sma/models/data_overview.dart';
import 'package:sma/models/profile/market_index.dart';
import 'package:sma/models/profile/stock_quote.dart';

class WatchlistClient {
  final FetchClient fetchClient;
  WatchlistClient (this.fetchClient);

  Future<List<MarketIndexModel>> fetchIndexes() async {
    final List<MarketIndexModel> response = await fetchClient.getIndexes();
    return response;
  }

  Future<StockOverviewModel> fetchStocks({String symbol}) async {
    final StockQuote stockQuote = await fetchClient.getQuote(symbol);
    return StockOverviewModel.fromStockQuote(stockQuote);
  }
}