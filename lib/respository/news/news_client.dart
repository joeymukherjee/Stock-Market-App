import 'package:dio/dio.dart';
import 'package:sma/keys/api_keys.dart';
import 'package:sma/models/news/news.dart';
import 'package:sma/models/news/single_new_model.dart';

class NewsClient {

  Future<NewsDataModel> fetchNews({String title}) async {

    final Uri newsUri = Uri.https('newsapi.org', '/v2/everything', {
      'q': '"$title"',
      'language': 'en',
      'sortBy': 'popularity',
      'pageSize': '10',
      'apikey': kNewsKey
    });

    final Response<dynamic> newsResponse = await Dio().getUri (newsUri);
    final List<SingleNewModel> newsOverviews = SingleNewModel.toList(newsResponse.data['articles']);

    return NewsDataModel(
      keyWord: title,
      news: newsOverviews,
    );
  }
}