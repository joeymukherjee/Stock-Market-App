import 'package:dio/dio.dart';
import 'package:sma/keys/api_keys.dart';

class FetchClient {
  final String baseUrl = 'cloud.iexapis.com';
  // final String baseUrl = 'sandbox.iexapis.com';

  Future<Response> fetchData({Uri uri}) async {
    return await Dio().getUri(uri);
  }

  Future<Response> post({Uri uri, Map<String, dynamic> data}) async {
    return await Dio().postUri(uri, data: data);
  }

  // Makes an HTTP request to any endpoint from IEX Cloud API.
  Future<Response> iexCloudRequest(String endpoint) async {
    final Uri uri = Uri.https(baseUrl, endpoint, {
      'types': 'quote',
      'token': kIEXCloudKey
    });
    // print ("iex_cloud_http_helper - " + uri.toString());
    return await Dio().getUri(uri);
  }

  Future<Response> iexCloudIndexesRequest () async {
    final Uri uri = Uri.https(baseUrl, '/stable/stock/market/batch/', {
      'symbols' : 'DIA,SPY,QQQ,IWM,VXX',
      'types': 'quote',
      'token': kIEXCloudKey
    });
    // print ("iex_cloud_http_helper - " + uri.toString());
    return await Dio().getUri(uri);
  }

  Future<Response> iexCloudChartRequest (String symbol) async {
    return await iexCloudRequest ('/stable/stock/$symbol/chart/1y/');
  }
  
  Future<Response> iexCloudProfileStats (String symbol) async {
    return await iexCloudRequest('/stable/stock/$symbol/stats');
  }
}
