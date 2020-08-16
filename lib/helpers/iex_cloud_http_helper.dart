import 'package:dio/dio.dart';
import 'package:sma/keys/api_keys.dart';

class FetchClient {
  final String baseUrl = useIEXCloudSandbox ? kIEXCloudSandboxBaseUrl : kIEXCloudBaseUrl;
  final String iexCloudKey = useIEXCloudSandbox ? kIEXCloudSandboxKey : kIEXCloudKey;

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
      'token': iexCloudKey
    });
    // print ("iex_cloud_http_helper - " + uri.toString());
    return await Dio().getUri(uri);
  }

  Future<Response> iexCloudIndexesRequest () async {
    final Uri uri = Uri.https(baseUrl, '/stable/stock/market/batch/', {
      'symbols' : 'DIA,SPY,QQQ,IWM,VXX',
      'types': 'quote',
      'token': iexCloudKey
    });
    // print ("iex_cloud_http_helper - " + uri.toString());
    return await Dio().getUri(uri);
  }

  Future<Response> iexCloudChartRequest (String symbol, String duration) async {
    return await iexCloudRequest ('/stable/stock/$symbol/chart/$duration/');
  }
  
  Future<Response> iexCloudProfileStats (String symbol) async {
    return await iexCloudRequest('/stable/stock/$symbol/stats');
  }
}
