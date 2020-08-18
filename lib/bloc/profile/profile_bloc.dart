import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import 'package:sma/helpers/iex_cloud_http_helper.dart';
import 'package:sma/helpers/financial_modeling_prep_http_helper.dart';

import 'package:sma/helpers/sentry_helper.dart';
import 'package:sma/models/profile/profile.dart';

import 'package:sma/respository/watchlist/storage_client.dart';
import 'package:sma/respository/profile/client.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  
  final _httpClient = ProfileClient(IEXFetchClient());
  final _storageClient = WatchlistStorageClient();

  @override
  ProfileState get initialState => ProfileInitial();

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
        isSymbolSaved: await this._storageClient.symbolExists(symbol: symbol)
      );

    } catch (e, stack) {
      yield ProfileLoadingError(error: 'Symbol not supported.');
      await SentryHelper(exception: e,  stackTrace: stack).report();
    }
  }
}
