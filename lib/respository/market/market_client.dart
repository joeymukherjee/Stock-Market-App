import 'package:dio/dio.dart';
import 'package:sma/helpers/fetch_client.dart';
import 'package:sma/models/markets/market_active/market_active.dart';
import 'package:sma/models/markets/market_active/market_active_model.dart';
import 'package:sma/models/markets/sector_performance/sector_performance_model.dart';

class MarketClient {
  final FetchClient fetchClient;
  MarketClient(this.fetchClient);

  /// Fetches sector performance and returns [SectorPerformanceModel].
  Future<SectorPerformanceModel> fetchSectorPerformance() async {

    final Response<dynamic> response = await Dio().getUri(
      Uri.https('www.alphavantage.co', '/query', {
        'function': 'SECTOR',
        'apikey': 'demo'
      })
    );

    return SectorPerformanceModel(
      performanceModelToday: SectorPerformanceDataModel.fromJson(response.data['Rank A: Real-Time Performance']),
    );
  }

  /// Fetches market most active stocks and retuns [MarketMoversModelData].
  Future<MarketMoversModelData> fetchMarketActive() async {
    final List<MarketActiveModel> response = await fetchClient.getMarketActives();
    return MarketMoversModelData(
      // marketActiveModelData: MarketMoversModelData.toList(response.data['mostActiveStock'])
      marketActiveModelData: response
    );
  }

  /// Fetches market most gainer stocks and retuns [MarketMoversModelData].
  Future<MarketMoversModelData> fetchMarketGainers() async {
    final List<MarketActiveModel> response = await fetchClient.getMarketGainers();
    return MarketMoversModelData(
      marketActiveModelData: response // ['mostGainerStock'])
    );
  }

  /// Fetches market most loser stocks and retuns [MarketMoversModelData].
  Future<MarketMoversModelData> fetchMarketLosers() async {
    final List<MarketActiveModel> response = await fetchClient.getMarketLosers();
    return MarketMoversModelData(
      marketActiveModelData: response // ['mostLoserStock'])
    );
  }
}