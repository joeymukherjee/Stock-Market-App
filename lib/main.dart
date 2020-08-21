import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sma/bloc/news/news_bloc.dart';
import 'package:sma/bloc/watchlist/watchlist_bloc.dart';
import 'package:sma/bloc/portfolio/folders_bloc.dart';
import 'package:sma/bloc/profile/profile_bloc.dart';
import 'package:sma/bloc/search/search_bloc.dart';
import 'package:sma/bloc/sector_performance/sector_performance_bloc.dart';

import 'package:sma/widgets/about/about.dart';
import 'package:sma/widgets/home.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {

  await DotEnv().load('.env');
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiBlocProvider(
      providers: [
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
      ],
      child: MaterialApp(
        title: 'Stock Market App',
        theme: ThemeData(brightness: Brightness.dark),
        home: StockMarketAppHome(),
        debugShowCheckedModeBanner: false,
        routes: {
          '/about': (context) => AboutSection(),
        },
      )
    )
  );
}