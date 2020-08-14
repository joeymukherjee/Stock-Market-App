
import 'package:flutter/material.dart';

class EditPortfolioFolderSection extends StatelessWidget {
  @override 
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold (
        appBar: AppBar (
          leading: Builder (
            builder: (BuildContext context) {
              return IconButton(icon: const Icon (Icons.add), 
                onPressed: () {
                  Navigator.pushNamed(context, '/add_portfolio_folder');
                }
              );
            }
          ),
          title: Text ('Edit Portfolios'),
          actions: <Widget>[
          IconButton(
            icon: Icon(Icons.done),
            tooltip: 'Done',
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
          bottom: TabBar(
            indicatorColor: Color(0X881f1f1f),
            indicatorPadding: EdgeInsets.symmetric(horizontal: 5),
            indicatorWeight: 1,
            tabs: [
              Tab(text: 'Total Return',),
              Tab(text: 'CAGR',),
              Tab(text: 'Value',),
            ],
          ),
        ),
      )
    );
  }
}