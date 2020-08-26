import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:sma/helpers/fetch_client.dart';
import 'package:dio/dio.dart';
import 'package:sma/helpers/sentry_helper.dart';
import 'package:sma/models/profile/profile.dart';

import 'package:sma/respository/watchlist/storage_client.dart';
import 'package:sma/respository/profile/client.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final _httpClient = ProfileClient(globalFetchClient);
  final _storageClient = WatchlistStorageClient();

  ProfileBloc () : super (ProfileInitial());

  @override
  Stream<ProfileState> mapEventToState(ProfileEvent event) async* {
    if (event is FetchProfileData) {
      yield ProfileLoading();
      yield* _mapProfileState(symbol: event.symbol);
    }
  }

  Stream<ProfileState> _mapProfileState({String symbol}) async* {
    try {
      yield ProfileLoaded(
          profileModel: await this._httpClient.fetchStockData(symbol: symbol),
          isSymbolSaved:
              await this._storageClient.symbolExists(symbol: symbol));
    } catch (error, stack) {
      var errorString;
      if (error is DioError) {
        DioError dioError = error;
        errorString = _handleError(dioError);
        yield ProfileLoadingError(error: 'Symbol not supported');
      } else {
        errorString = "Unknown error!";
        await SentryHelper(exception: error, stackTrace: stack).report();
      }
      yield ProfileLoadingError(error: 'Symbol not supported. $errorString');
    }
  }

  String _handleError(DioError dioError) {
    String errorDescription = "";
    switch (dioError.type) {
      case DioErrorType.CANCEL:
        errorDescription = "Request to API server was cancelled";
        break;
      case DioErrorType.CONNECT_TIMEOUT:
        errorDescription = "Connection timeout with API server";
        break;
      case DioErrorType.DEFAULT:
        errorDescription =
            "Connection to API server failed due to internet connection";
        break;
      case DioErrorType.RECEIVE_TIMEOUT:
        errorDescription = "Receive timeout in connection with API server";
        break;
      case DioErrorType.RESPONSE:
        errorDescription =
            "Received invalid status code: ${dioError.response.statusCode}";
        break;
      case DioErrorType.SEND_TIMEOUT:
        errorDescription = "Send timeout in connection with API server";
        break;
    }
    return errorDescription;
  }
}
