import 'package:sma/models/profile/profile.dart';
import 'package:sma/models/profile/stock_chart.dart';
import 'package:sma/helpers/fetch_client.dart';
import 'package:sma/models/profile/stock_profile.dart';
import 'package:sma/models/profile/stock_quote.dart';

class ProfileClient {
  final FetchClient fetchClient;
  ProfileClient(this.fetchClient);

  Future<StockQuote> fetchProfileChanges({String symbol}) async {
    final StockQuote stockQuote = await fetchClient.getQuote (symbol);
    return stockQuote;
  }
  
  Future<ProfileModel> fetchStockData({String symbol}) async {
    final StockProfile stockProfile = await fetchClient.getCompanyProfile (symbol);
    final StockQuote stockQuote = await fetchClient.getQuoteFull(symbol);
    final List<StockChart> stockChart = await fetchClient.getChart(symbol, '1y');
    return ProfileModel(
      stockQuote: stockQuote,
      stockProfile: stockProfile,
      stockChart: stockChart,
    );
  }

  Future<List<StockChart>> fetchChart({String symbol, String duration}) async {
    return await fetchClient.getChart(symbol, duration);
  }
}