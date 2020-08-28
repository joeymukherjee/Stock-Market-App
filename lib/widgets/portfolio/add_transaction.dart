import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:date_field/date_field.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sma/bloc/trade/trades_bloc.dart';
import 'package:sma/models/trade/trade.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:sma/shared/styles.dart';

class AddTransactionHeading extends StatelessWidget {

  void clickedBack (BuildContext context, TradesState state) {
    print (state);
    if (state is TradeGroupsLoadedEditing) {
      BlocProvider.of<TradesBloc>(context).add(PickedPortfolio(portfolioId));
    }
  }

  final TradesState previousState;
  final String portfolioName;
  final int portfolioId;
  AddTransactionHeading ({@required this.portfolioName, @required this.portfolioId, @required this.previousState});
  @override
  Widget build(BuildContext context) {
    return BlocListener<TradesBloc, TradesState> (
      listener: (context, state) {
        if (state is TradesSavedOkay) {
          Navigator.pop(context);
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  child: Icon(Icons.arrow_back_ios),
                  onTap: () => {
                    clickedBack (context, previousState),
                    Navigator.pop(context)
                  }
                ),
                Expanded(child: Text('Add Transaction', style: kPortfolioHeaderTitle, textAlign: TextAlign.center)),
                GestureDetector(
                  child: Icon(Icons.done),
                  onTap: () => {
                    BlocProvider.of<TradesBloc>(context).add(FinishedTransaction())
                  }
                ),
              ],
            ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 15.0), // space below portfolio name, above tab bar
                child: Row (
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text (portfolioName)]
                ),
            ),
          ],
        )
      ),
    );
  }
}

class AddTransactionContents extends StatefulWidget {
  final String portfolioName;
  final int portfolioId;
  AddTransactionContents ({@required this.portfolioName, @required this.portfolioId});

  @override
  _AddTransactionContentsState createState() => _AddTransactionContentsState();
}

class _AddTransactionContentsState extends State<AddTransactionContents> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  TabController _tabController;

  int _portfolioId;
  final moneyEditController = MoneyMaskedTextController();
  String _ticker = 'AAPL';
  DateTime _transactionDate = DateTime.parse('2011-03-11 00:00:00');
  // These quantities are money
  double _price = 454.12;
  double _commission = 0.0;
  double _paid = 5449.44;
  double _amountPerShare = 0.0;
  double _proceeds = 0.0;
  bool _didReinvest = true;
  double _priceAtReinvest = 0.0;
  // These quantities are strings since we have to parse them ourselves into doubles
  String _sharesTransacted = "12.0";
  String _sharesFrom = "0.0";
  String _sharesTo = "0.0";

  double _totalNumberOfShares = 0.0;  // These are for dividends, should be computed somehow from DB?

  @override
  void initState () {
    _portfolioId = widget.portfolioId;
    _tabController = new TabController(length: 4, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void createTrade (BuildContext context) {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      Trade trade;
      final int index = _tabController.index;
      switch (index) {
        case 0 : trade = Common(type: TransactionType.purchase, portfolioId: this._portfolioId, ticker: this._ticker, transactionDate: this._transactionDate, sharesTransacted: double.parse(this._sharesTransacted), price: this._price, commission: this._commission); break;
        case 1 : trade = Common(type: TransactionType.sell, portfolioId: this._portfolioId, ticker: this._ticker, transactionDate: this._transactionDate, sharesTransacted: -(double.parse(this._sharesTransacted)), price: this._price, commission: this._commission); break;
        case 2 : trade = Dividend(this._portfolioId, this._ticker, this._transactionDate, double.parse(this._sharesTransacted), this._price, this._commission, this._totalNumberOfShares, this._amountPerShare, this._didReinvest, this._priceAtReinvest); break;
        case 3 : trade = Split(this._portfolioId, this._ticker, this._transactionDate, this._price, double.parse(this._sharesFrom), double.parse(this._sharesTo)); break;
      }
      BlocProvider.of<TradesBloc>(context).add(DidTrade(trade));
    } else {
      BlocProvider.of<TradesBloc>(context).add(AddedTransaction());  // This is going back to our original condition
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double tabWidth = width / 5;
    double labelPadding = tabWidth / 8;

    return BlocBuilder<TradesBloc, TradesState> (
      builder: (BuildContext context, TradesState state) {
        if (state is TradesFinishedEditing) {
            createTrade (context);
        }
        return Form(
          key: _formKey,
          child: Column (
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: Theme.of(context).tabBarTheme.labelColor,
                labelPadding: EdgeInsets.symmetric(horizontal: labelPadding),
                unselectedLabelColor: Theme.of(context).tabBarTheme.unselectedLabelColor,
                indicatorSize: TabBarIndicatorSize.label,
                //indicatorPadding: EdgeInsets.all(10.0),
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Theme.of(context).highlightColor),
                tabs: [
                  Tab(child: Container(
                        width: tabWidth,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(color: Theme.of(context).primaryColor, width: 1)),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text("Buy", textScaleFactor: 1.0),
                        ),
                      ),
                    ),
                  Tab(child: Container(
                        width: tabWidth,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(color: Theme.of(context).primaryColor, width: 1)),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text("Sell", textScaleFactor: 1.0),
                        ),
                      ),
                    ),
                  Tab(child: Container(
                        width: tabWidth,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(color: Theme.of(context).primaryColor, width: 1)),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text("Dividend", softWrap: false, overflow: TextOverflow.visible, textScaleFactor: 1.0),
                        ),
                      ),
                    ),
                  Tab(child: Container(
                        width: tabWidth,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(color: Theme.of(context).primaryColor, width: 1)),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text("Split", textScaleFactor: 1.0)
                        ),
                      ),
                    ),
                ]
              ),
              Container(
                height: MediaQuery.of(context).size.height - MediaQuery.of(context).viewInsets.bottom - 305,
                child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildBuyItems (context, this),
                        _buildSellItems (context, this),
                        _buildDividendItems (context, this),
                        _buildSplitItems (context, this)
                      ]
                    ),
              ),
            ] 
          ),
        );
      }
    );
  }
}

List<Widget> _buildCommonItems (context, widget) {
  return [
    Padding(
      padding: const EdgeInsets.all(8.0),  // without this extra, Ticker Name was up under the tabs??
      child: Container(),
    ),
    TextFormField(
      initialValue: widget._ticker,
      textCapitalization: TextCapitalization.characters,
      decoration: InputDecoration (hintText: 'ticker name', labelText: "Ticker Name"),
      showCursor: true,
      validator: (value) {
        if (value.isEmpty) {
          return ('this value can not be empty!');
        }
        return null;
      },
      onSaved: (String value) {
        widget._ticker = value;
      }
    ),
    DateTimeFormField(
      mode: DateFieldPickerMode.date,
      initialValue: widget._transactionDate,
      validator: (value) {
        if (value == null) {
          return ('this value can not be empty!');
        }
        return null;
      },
      onDateSelected: (DateTime date) {
        widget.setState(() {
          widget._transactionDate = date;
        });
      },
      lastDate: DateTime.now(),
    ),
  ];
}

List<Widget> _buildCommonBuySellItems (context, widget) {
  return [
      TextFormField(
        initialValue: widget._sharesTransacted,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp('[\\.0-9]*'))
        ],
        decoration: InputDecoration (hintText: 'number of shares', labelText: "Shares"),
        validator: (value) {
          if (value.isEmpty) {
            return ('enter the number of shares for this transaction');
          }
          if (double.tryParse(value) == null) {
            return ('must be a valid number!');
          }
          return null;
        },
        showCursor: true,
        onSaved: (String value) async {
          widget._sharesTransacted = value;
        }
      ),
      TextFormField(
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        controller: MoneyMaskedTextController(initialValue: widget._price, decimalSeparator: '.', thousandSeparator: ','),
        decoration: InputDecoration (hintText: 'price of share', labelText: "Price"),
        showCursor: true,
        validator: (value) {
          if (value.isEmpty) {
            return ('enter the cost of the stock when this transaction occurred');
          }
          if (double.tryParse(value) == null) {
            return ('must be a valid number!');
          }
          return null;
        },
        onSaved: (String value) async {
          widget._price = double.parse(value);
        }
      ),
      TextFormField(
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        controller: MoneyMaskedTextController(initialValue: widget._commission, decimalSeparator: '.', thousandSeparator: ','),
        decoration: InputDecoration (hintText: 'commission paid', labelText: "Commission"),
        showCursor: true,
        validator: (value) {
          if (value.isEmpty) {
            return ('enter the number of amount you paid in commission for this transaction');
          }
          if (double.tryParse(value) == null) {
            return ('must be a valid number!');
          }
          return null;
        },
        onSaved: (String value) async {
          widget._commission = double.parse(value);
        }
      )
  ];
}

Widget _buildBuyItems (context, widget) {
  return ListView (
    shrinkWrap: true,
    children: _buildCommonItems(context, widget) + _buildCommonBuySellItems(context, widget) + [
      TextFormField(
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        controller: MoneyMaskedTextController(initialValue: widget._paid, decimalSeparator: '.', thousandSeparator: ','),
        decoration: InputDecoration (hintText: 'amount paid', labelText: "Paid"),
        showCursor: true,
        validator: (value) {
          if (value.isEmpty) {
            return ('enter the number of amount you received for this transaction');
          }
          if (double.tryParse(value.replaceAll (',', '')) == null) {
            return ('must be a valid number!');
          }
          return null;
        },
        onSaved: (String value) async {
          widget._paid = double.parse (value.replaceAll (',', '')); // widget._price * double.parse(widget._sharesTransacted) - widget._commission;
        }
      )
    ],
  );
}

Widget _buildSellItems (context, widget) {
  return ListView (
    shrinkWrap: true,
    children: _buildCommonItems(context, widget) + _buildCommonBuySellItems (context, widget) + [
      TextFormField(
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        controller: MoneyMaskedTextController(initialValue: widget._paid, decimalSeparator: '.', thousandSeparator: ','),
        decoration: InputDecoration (hintText: 'amount received', labelText: "Proceeds"),
        showCursor: true,
        validator: (value) {
          if (value.isEmpty) {
            return ('enter the number of amount you received for this transaction');
          }
          if (double.tryParse(value) == null) {
            return ('must be a valid number!');
          }
          return null;
        },
        onSaved: (String value) async {
          widget._paid = widget._price * widget._sharesTransacted - widget._commission;
        }
      )
    ],
  );
}

Widget _buildDividendItems (context, widget) {
  List<Widget> allChildren = _buildCommonItems (context, widget) + [
      Row (
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text ("Total Shares"),
          Text ("fill in shares")
        ],
      ),
      TextFormField(
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        controller: MoneyMaskedTextController(initialValue: widget._amountPerShare, decimalSeparator: '.', thousandSeparator: ','),
        decoration: InputDecoration (hintText: 'amount per share', labelText: "Amount per Share"),
        showCursor: true,
        validator: (value) {
          if (value.isEmpty) {
            return ('enter the number of amount you received per share');
          }
          if (double.tryParse(value) == null) {
            return ('must be a valid number!');
          }
          return null;
        },
        onSaved: (String value) async {
          widget._amountPerShare = double.parse(value);
        }
      ),
      TextFormField(
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        controller: MoneyMaskedTextController(initialValue: widget._proceeds, decimalSeparator: '.', thousandSeparator: ','),
        decoration: InputDecoration (hintText: 'dividend amount', labelText: "Dividend"),
        showCursor: true,
        validator: (value) {
          if (value.isEmpty) {
            return ('enter the total amount you received for this dividend');
          }
          if (double.tryParse(value) == null) {
            return ('must be a valid number!');
          }
          return null;
        },
        onSaved: (String value) async {
          widget._proceeds = double.parse(value);
        }
      ),
      Row(
          children: [
            Text("Reinvest Dividend:"),
            Switch(value: widget._didReinvest,
              onChanged: (bool value) {
               widget.setState(() {
                 widget._didReinvest = value;
                });
            }),
          ],
        ),
    ];
  if (widget._didReinvest) allChildren = allChildren + _buildCommonBuySellItems(context, widget);
  return ListView(children: allChildren, shrinkWrap: true);
}

Widget _buildSplitItems (context, widget) {
  return ListView (
    shrinkWrap: true,
    children: _buildCommonItems (context, widget) + [
      TextFormField(
        initialValue: widget._sharesTransacted,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp('[\\.0-9]*'))
        ],
        decoration: InputDecoration (hintText: 'number of shares', labelText: "Shares"),
        showCursor: true,
        validator: (value) {
          if (value.isEmpty) {
            return ('enter the number of shares you held for this transaction');
          }
          if (double.tryParse(value) == null) {
            return ('must be a valid number!');
          }
          return null;
        },
        onSaved: (String value) async {
           widget._sharesTransacted = double.parse(value);
        }
      ),
      TextFormField(
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        controller: MoneyMaskedTextController(initialValue: widget._priceAtReinvest, decimalSeparator: '.', thousandSeparator: ','),
        decoration: InputDecoration (hintText: 'price after split', labelText: "Price After"),
        validator: (value) {
          if (value.isEmpty) {
            return ('enter the price per share after the split occurred');
          }
          if (double.tryParse(value) == null) {
            return ('must be a valid number!');
          }
          return null;
        },
        showCursor: true,
        onSaved: (String value) async {
          widget._priceAtReinvest = double.parse(value);
        }
      ),
      TextFormField(
        initialValue: widget._sharesFrom,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp('[\\.0-9]*'))
        ],
        decoration: InputDecoration (hintText: 'number of shares before split', labelText: "Shares From"),
        showCursor: true,
        validator: (value) {
          if (value.isEmpty) {
            return ('enter the number of shares you had before the split');
          }
          if (double.tryParse(value) == null) {
            return ('must be a valid number!');
          }
          return null;
        },
        onSaved: (String value) async { 
          widget._sharesFrom = double.parse(value);
        }
      ),
      TextFormField(
        initialValue: widget._sharesTo,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp('[\\.0-9]*'))
        ],
        decoration: InputDecoration (hintText: 'number of shares after split', labelText: "Shares To"),
        validator: (value) {
          if (value.isEmpty) {
            return ('enter the number of shares you had after the split');
          }
          if (double.tryParse(value) == null) {
            return ('must be a valid number!');
          }
          return null;
        },
        showCursor: true,
        onSaved: (String value) async {
          widget._sharesTo = double.parse(value);
        }
      ),
    ],
  );
}

class AddTransaction extends StatelessWidget {
  final TradesState previousState;
  final int portfolioId;
  final String portfolioName;

  AddTransaction ({@required this.portfolioName, @required this.portfolioId, @required this.previousState});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column (
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              AddTransactionHeading (portfolioId: portfolioId, portfolioName: portfolioName, previousState: previousState),
              AddTransactionContents (portfolioId: portfolioId, portfolioName: portfolioName),
          ]
        ),
      ),
    );
  }
}