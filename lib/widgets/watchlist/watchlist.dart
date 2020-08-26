import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_offline/flutter_offline.dart';

import 'package:sma/bloc/watchlist/watchlist_bloc.dart';
import 'package:sma/widgets/watchlist/watchlist_stonks.dart';

import 'package:sma/widgets/watchlist/widgets/heading/watchlist_heading.dart';
import 'package:sma/widgets/widgets/empty_screen.dart';

class WatchlistSection extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OfflineBuilder(
        child: Container(),
        connectivityBuilder: ( context,  connectivity, child,  ) {
          return connectivity == ConnectivityResult.none 
          ? _buildNoConnectionMessage(context)
          : _buildContent(context);
        }
      )
    );
  }

  Widget _buildNoConnectionMessage(context) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).size.height / 14,
        left: 24,
        right: 24
      ),
      child: EmptyScreen(message: 'Looks like you don\'t have an internet connection.'),
    );
  }

  Widget _buildContent(context) {
    return RefreshIndicator(
      child: SafeArea(
        child: ListView(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            WatchlistHeadingSection(),
            WatchlistStonksSection()
          ]
        )
      ),

      onRefresh: () async {
        // Reload stocks section.
        BlocProvider
        .of<WatchlistBloc>(context)
        .add(FetchWatchlistData());
      },
    );
  }

}