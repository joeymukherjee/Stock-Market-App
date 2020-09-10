import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sma/models/portfolio/folder.dart';
import 'package:sma/models/trade/trade_group.dart';
import 'package:sma/widgets/widgets/loading_indicator.dart';
import 'package:sma/widgets/widgets/empty_screen.dart';
import 'package:sma/bloc/trade/trades_bloc.dart';
import 'package:sma/widgets/portfolio/widgets/content/porfolio_folder_stocks_card.dart';

class PortfolioFolderSection extends StatefulWidget {
  final PortfolioFolderModel folder;

  PortfolioFolderSection ({@required this.folder});

  @override
  _PortfolioFolderSectionState createState() => _PortfolioFolderSectionState();
}

class _PortfolioFolderSectionState extends State<PortfolioFolderSection> {

  List<TradeGroup> _tradeGroups;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TradesBloc, TradesState>(
      builder: (BuildContext context, TradesState state) {
        print (state);
        if (state is TradesSavedOkay) {
          BlocProvider
            .of<TradesBloc>(context)
            .add(PickedPortfolio(widget.folder.id));
        }
        if (state is TradesEmpty) {
          return Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height / 10,
                  horizontal: 4
                ),
                child: EmptyScreen(message: 'Looks like you don\'t have any transactions on ${widget.folder.name}.  Add one by clicking the "Add" icon above!'),
              ),
            ],
          );
        }
        if (state is TradesFailure) {
          return Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 3),
            child: EmptyScreen(message: state.message),
          );
        }
        if (state is TradeGroupsLoadedEditing) {
          return Expanded(
            child: _buildReorderableList(tradeGroups: state.tradeGroups)
          );
        }
        if (state is TradeGroupsLoadSuccess) {
          _tradeGroups = state.tradeGroups;
          return Expanded(
            child: _buildFolderSection(tradeGroups: state.tradeGroups)
          );
        }
        return Expanded(
          child: Padding(
              padding: EdgeInsets.only(top: 20),
              child: LoadingIndicatorWidget(),
            ),
        );
      }
    );
  }

  Widget _getTile (TradeGroup item) {
    return ListTile(
      key: Key(item.ticker),
      leading: Icon(Icons.highlight_off, color: Colors.blue),
      title: Text(item.ticker, textAlign: TextAlign.center),
      trailing: Icon(Icons.menu),
    );
  }

  Widget _buildReorderableList ({List<TradeGroup> tradeGroups}) {
    return ReorderableListView(
      onReorder: (oldIndex, newIndex) {
        setState (
          () {
              TradeGroup old = tradeGroups[oldIndex];
              if (oldIndex > newIndex) {
                for (int i = oldIndex; i > newIndex; i--) {
                  tradeGroups[i] = tradeGroups[i - 1];
                }
                tradeGroups[newIndex] = old;
              } else {
                for (int i = oldIndex; i < newIndex - 1; i++) {
                  tradeGroups[i] = tradeGroups[i + 1];
                }
                tradeGroups[newIndex - 1] = old;
              }
              _tradeGroups.clear();
              tradeGroups.forEach((element) { _tradeGroups.add(TradeGroup.newOrder(element, _tradeGroups.length)); });
          });
      },
      children: tradeGroups.map((item) => _getTile(item)).toList()
    );
  }

  Widget _buildFolderSection({List<TradeGroup> tradeGroups}) {
    return ListView.builder(
      key: const PageStorageKey("stocks"),  // allows folder to remember position!
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      itemCount: tradeGroups.length,
      itemBuilder: (BuildContext context, int index) {
        return PortfolioFolderStocksCard (tradeGroup: tradeGroups[index]);
      }
    );
  }
}