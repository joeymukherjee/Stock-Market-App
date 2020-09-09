import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sma/bloc/authentication/authentication_bloc.dart';
import 'package:sma/shared/styles.dart';

import 'package:sma/bloc/news/news_bloc.dart';
import 'package:sma/bloc/settings/settings_bloc.dart';
import 'package:sma/bloc/watchlist/watchlist_bloc.dart';
import 'package:sma/bloc/portfolio/folders_bloc.dart';
import 'package:sma/bloc/profile/profile_bloc.dart';
import 'package:sma/bloc/search/search_bloc.dart';
import 'package:sma/bloc/sector_performance/sector_performance_bloc.dart';
import 'package:sma/bloc/trade/trades_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sma/widgets/about/about.dart';
import 'package:sma/widgets/home.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {

  await DotEnv().load('.env');
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseAnalytics analytics = FirebaseAnalytics();
  FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  final prefs = await SharedPreferences.getInstance();
  bool initialTheme = prefs.getBool('theme') == null ? true : prefs.getBool('theme');

  runApp(
    DevicePreview(
      enabled: false,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<AuthenticationService>(
            create: (context){
              return FirebaseEmailPassword();
            },
          ),
          BlocProvider<AuthenticationBloc>(
            create: (context) {
              final authService = RepositoryProvider.of<AuthenticationService>(context);
              return AuthenticationBloc(authService)..add(AppLoaded());
            }
          ),
          BlocProvider<SettingsBloc>(
            create: (context) => SettingsBloc(initialTheme)
          ),
          BlocProvider<WatchlistBloc>(
            create: (context) => WatchlistBloc(),
          ),
          BlocProvider<PortfolioFoldersBloc>(
            create: (context) => PortfolioFoldersBloc(),
          ),
          BlocProvider<ProfileBloc>(
            create: (context) => ProfileBloc(),
          ),
          BlocProvider<SearchBloc>(
            create: (context) => SearchBloc(),
          ),
          BlocProvider<SectorPerformanceBloc>(
            create: (context) => SectorPerformanceBloc(),
          ),
          BlocProvider<NewsBloc>(
            create: (context) => NewsBloc(),
          ),
          BlocProvider<TradesBloc>(
            create: (context) => TradesBloc(),
          ),
        ],
        child: BlocBuilder <SettingsBloc, SettingsState> (
          builder: (context, state) {
            return MaterialApp(
              locale: DevicePreview.of(context).locale,
              builder: DevicePreview.appBuilder,
              title: 'StonksJM',
              theme: state.isNight ? darkMode : lightMode,
              navigatorObservers: <NavigatorObserver>[observer],
              home: StockMarketAppHome(),
              debugShowCheckedModeBanner: true,
              routes: {
                '/about': (context) => AboutSection(),
              },
            );
          }
        )
      ),
    )
  );
}