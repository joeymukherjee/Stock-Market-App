import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:date_field/date_field.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sma/bloc/trade/trades_bloc.dart';
import 'package:sma/models/trade/trade.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:sma/shared/styles.dart';
import 'package:sma/respository/trade/trades_repo.dart';

class TransactionHeading extends StatelessWidget {

  final String prefix;
  final String portfolioName;
  final String portfolioId;

  TransactionHeading ({@required this.prefix, @required this.portfolioName, @required this.portfolioId});

  @override
  Widget build(BuildContext context) {
    return BlocListener<TradesBloc, TradesState> (
      listener: (context, state) {
        if (state is TradesSavedOkay) {
          Navigator.pop(context);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  child: Icon(Icons.arrow_back_ios),
                  onTap: () => { Navigator.pop(context) }
                ),
                Expanded(child: Text(prefix + ' Transaction', style: kPortfolioHeaderTitle, textAlign: TextAlign.center)),
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

class TransactionContents extends StatefulWidget {
  final String portfolioName;
  final String portfolioId;
  final Trade trade;
  TransactionContents ({@required this.portfolioName, @required this.portfolioId, @required this.trade});

  @override
  _TransactionContentsState createState() => _TransactionContentsState();
}

class _TransactionContentsState extends State<TransactionContents> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  TabController _tabController;
  String _tradeId;
  String _portfolioId;

  final moneyEditController = MoneyMaskedTextController();
  String _ticker = '';
  DateTime _transactionDate = DateTime.now();
  // These quantities are money
  double _price = 0.0;
  double _commission = 0.0;
  double _paid = 0.0;
  double _amountPerShare = 0.0;
  double _proceeds = 0.0;
  bool _didReinvest = true;

  // These quantities are strings since we have to parse them ourselves into doubles
  String _numberOfShares = "";
  String _sharesTransacted = "";
  String _sharesFrom = "";
  String _sharesTo = "";

  @override
  void initState () {
    super.initState();
    _tabController = new TabController(length: 4, vsync: this);
    if (widget.trade == null) {

    } else {
      _tradeId = widget.trade.id;
      _ticker = widget.trade.ticker;
      _transactionDate = widget.trade.transactionDate;
      if (widget.trade.type != TransactionType.split) {
        Common c = widget.trade as Common;
        _price = c.price;
        _commission = c.commission;
        _paid = c.paid;
        _sharesTransacted = c.sharesTransacted.toString();
        _tabController.index = widget.trade.type == TransactionType.sell ? 1 : 0;
      } else {
        Split s = widget.trade as Split;
        _sharesFrom = s.sharesFrom.toString();
        _sharesTo = s.sharesTo.toString();
        _tabController.index = 3;
      }
      if (widget.trade.type == TransactionType.dividend) {
        _tabController.index = 2;
        Dividend d = widget.trade as Dividend;
        _numberOfShares = d.numberOfShares.toString();
        _amountPerShare = d.amountPerShare;
        _didReinvest = d.didReinvest;
        _proceeds = d.proceeds == 0.0 ? _amountPerShare * d.numberOfShares : d.proceeds;
      }
    }
    _portfolioId = widget.portfolioId;
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
        case 0 : trade = Common.withId(id: this._tradeId, type: TransactionType.purchase, portfolioId: this._portfolioId, ticker: this._ticker, transactionDate: this._transactionDate, sharesTransacted: double.parse(this._sharesTransacted), price: this._price, commission: this._commission); break;
        case 1 : trade = Common.withId(id: this._tradeId, type: TransactionType.sell, portfolioId: this._portfolioId, ticker: this._ticker, transactionDate: this._transactionDate, sharesTransacted: double.parse(this._sharesTransacted), price: this._price, commission: this._commission); break;
        case 2 : trade = Dividend.withId(id: this._tradeId, portfolioId: this._portfolioId, ticker: this._ticker, transactionDate: this._transactionDate, sharesTransacted: double.parse(this._sharesTransacted), price: this._price, commission: this._commission, numberOfShares: double.parse (this._numberOfShares), amountPerShare: this._amountPerShare, didReinvest: this._didReinvest); break;
        case 3 : trade = Split.withId(id: this._tradeId, portfolioId: this._portfolioId, ticker: this._ticker, transactionDate: this._transactionDate, sharesFrom: double.parse(this._sharesFrom), sharesTo: double.parse(this._sharesTo)); break;
      }
      BlocProvider.of<TradesBloc>(context).add(DidTrade(trade));
    } else {
      BlocProvider.of<TradesBloc>(context).add(AddedTransaction());  // This is going back to our original condition
    }
  }

  void computeTotalSharesForDividend () async {
    final TradesRepository _tradesRepo = globalTradesDatabase;
      List<Trade> _trades = await _tradesRepo.loadAllTradesForTickerAndPortfolioAndDate(_ticker, widget.portfolioId, _transactionDate);
      double totalShares = 0.0;
      _trades.forEach ((trade) => {
        totalShares += trade.getNumberOfShares()
      });
      _sharesTransacted = totalShares.toString();
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
      autocorrect: false,
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
  double _price = widget._price;
  double _commission = widget._commission;

  var priceController = MoneyMaskedTextController(initialValue: widget._price, leftSymbol: '\$', decimalSeparator: '.', thousandSeparator: ',', precision: 2);
  priceController.afterChange = (String masked, double raw) {
    _price = raw;
  };
  var commissionController = MoneyMaskedTextController(initialValue: widget._commission, leftSymbol: '\$', decimalSeparator: '.', thousandSeparator: ',', precision: 2);
  commissionController.afterChange = (String masked, double raw) {
    _commission = raw;
  };
  return [
      Focus(
        child: TextFormField(
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
          onChanged: (String value) {
            widget._sharesTransacted = value;
          },
          onSaved: (String value) async {
            widget._sharesTransacted = value;
          }
        ),
        onFocusChange: (bool hasFocus) {
          if (!hasFocus) {
            var value = widget._sharesTransacted;
            if (double.tryParse(value.replaceAll (',\$', '')) != null) {
              widget.setState (() { widget._paid = widget._price * double.parse(value) - widget._commission; });
            }
          }
        },
      ),
      Focus(
        child: TextFormField(
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          controller: priceController,
          decoration: InputDecoration (hintText: 'price of share', labelText: "Price"),
          showCursor: true,
          validator: (value) {
            if (value.isEmpty) {
              return ('enter the cost of the stock when this transaction occurred');
            }
            if (double.tryParse(value.replaceAll (RegExp('[,\$]'), '')) == null) {
              return ('must be a valid number!');
            }
            return null;
          },
          onSaved: (String value) async {
            widget._price = priceController.numberValue;
          }
        ),
        onFocusChange: (bool hasFocus) {
          if (!hasFocus) {
            if (double.tryParse(widget._sharesTransacted) != null) {
              widget.setState (() { widget._price = _price; widget._paid = _price * double.parse(widget._sharesTransacted) - widget._commission; });
            }
          }
        },
      ),
      Focus(
        child: TextFormField(
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          controller: commissionController,
          decoration: InputDecoration (hintText: 'commission paid', labelText: "Commission"),
          showCursor: true,
          validator: (value) {
            if (value.isEmpty) {
              return ('enter the number of amount you paid in commission for this transaction');
            }
            if (double.tryParse(value.replaceAll (RegExp('[,\$]'), '')) == null) {
              return ('must be a valid number!');
            }
            return null;
          },
          onSaved: (String value) async {
            widget._commission = commissionController.numberValue;
          }
        ),
        onFocusChange: (bool hasFocus) {
          if (!hasFocus) {
            if (double.tryParse(widget._sharesTransacted) != null) {
              widget.setState (() { widget._commission = _commission; widget._paid = widget._price * double.parse(widget._sharesTransacted) - widget._commission; });
            }
          }
        },
      )
  ];
}

Widget _buildBuyItems (context, widget) {
  return ListView (
    shrinkWrap: true,
    children: _buildCommonItems(context, widget) + _buildCommonBuySellItems(context, widget) + [
      TextFormField(
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        controller: MoneyMaskedTextController(initialValue: widget._paid, decimalSeparator: '.', thousandSeparator: ',', leftSymbol: '\$'),
        decoration: InputDecoration (hintText: 'amount paid', labelText: "Paid"),
        showCursor: true,
        validator: (value) {
          if (value.isEmpty) {
            return ('enter the number of amount you received for this transaction');
          }
          if (double.tryParse(value.replaceAll (RegExp('[,\$]'), '')) == null) {
            return ('must be a valid number!');
          }
          return null;
        },
        onSaved: (String value) async {
          widget._paid = double.parse (value.replaceAll (RegExp('[,\$]'), ''));
        }
      )
    ],
  );
}

Widget _buildSellItems (context, widget) {
  return ListView (
    shrinkWrap: true,
    children: _buildCommonItems(context, widget) + _buildCommonBuySellItems(context, widget) + [
      TextFormField(
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        controller: MoneyMaskedTextController(initialValue: widget._paid, decimalSeparator: '.', thousandSeparator: ','),
        decoration: InputDecoration (hintText: 'amount received', labelText: "Proceeds"),
        showCursor: true,
        validator: (value) {
          if (value.isEmpty) {
            return ('enter the number of amount you received for this transaction');
          }
          if (double.tryParse(value.replaceAll (RegExp('[,\$]'), '')) == null) {
            return ('must be a valid number!');
          }
          return null;
        },
        onSaved: (String value) async {
          widget._paid = double.parse (value.replaceAll (RegExp('[,\$]'), ''));
        }
      )
    ],
  );
}

Widget _buildDividendItems (context, widget) {
  double _perShare = widget._amountPerShare;
  double _proceeds = widget._proceeds;

  var perShareController = MoneyMaskedTextController(initialValue: widget._amountPerShare, leftSymbol: '\$', decimalSeparator: '.', thousandSeparator: ',', precision: 2);
  perShareController.afterChange = (String masked, double raw) {
    _perShare = raw;
  };
  var proceedsController = MoneyMaskedTextController(initialValue: widget._proceeds, leftSymbol: '\$', decimalSeparator: '.', thousandSeparator: ',', precision: 2);
  proceedsController.afterChange = (String masked, double raw) {
    _proceeds = raw;
  };
  List<Widget> allChildren = _buildCommonItems (context, widget) + [
      Focus(
        child: TextFormField(
          initialValue: widget._numberOfShares,
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
          onChanged: (String value) {
            widget._numberOfShares = value;
          },
          onSaved: (String value) async {
            widget._numberOfShares = value;
          }
        ),
        onFocusChange: (bool hasFocus) {
          if (!hasFocus) {
            var value = widget._numberOfShares;
            if (double.tryParse(value) != null) {
              _proceeds = _perShare * double.parse(value);
              widget.setState (() { widget._numberOfShares = value; widget._proceeds = _proceeds; });
            }
          }
        },
      ),
      Focus(
        child: TextFormField(
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          controller: perShareController,
          decoration: InputDecoration (hintText: 'amount per share', labelText: "Amount per Share"),
          showCursor: true,
          validator: (value) {
            if (value.isEmpty) {
              return ('enter the number of amount you received per share');
            }
            if (double.tryParse(value.replaceAll (RegExp('[,\$]'), '')) == null) {
              return ('must be a valid number!');
            }
            return null;
          },
          onSaved: (String value) async {
            widget._amountPerShare = perShareController.numberValue;
          }
        ),
        onFocusChange: (bool hasFocus) {
          if (!hasFocus) {
            if (double.tryParse(widget._numberOfShares) != null) {
              _proceeds = _perShare * double.parse(widget._numberOfShares);
              widget.setState (() { widget._proceeds = _proceeds; widget._amountPerShare = _perShare; });
            }
          }
        },
      ),
      Focus(
        child: TextFormField(
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          controller: proceedsController,
          decoration: InputDecoration (hintText: 'dividend amount', labelText: "Dividend"),
          showCursor: true,
          validator: (value) {
            if (value.isEmpty) {
              return ('enter the total amount you received for this dividend');
            }
            if (double.tryParse(value.replaceAll (RegExp('[,\$]'), '')) == null) {
              return ('must be a valid number!');
            }
            return null;
          },
          onSaved: (String value) async {
            widget._proceeds = _proceeds;
          }
        ),
      ),
      Row(
          children: [
            Text("Reinvest Dividend:"),
            Switch.adaptive(value: widget._didReinvest,
              onChanged: (bool didReinvest) {
               widget.setState(() {
                 widget._didReinvest = didReinvest;
                 if (!didReinvest) {
                   widget._price = 0.0;
                   widget._sharesTransacted = "0.0";
                   widget._commission = 0.0;
                 }
                });
            }),
          ],
        ),
    ];
  if (widget._didReinvest) allChildren = allChildren + _buildCommonBuySellItems(context, widget);
  return ListView(children: allChildren, shrinkWrap: true);
}

Widget _buildSplitItems (context, widget) {
  //double _price = widget._price;
  var priceController = MoneyMaskedTextController(initialValue: widget._price, leftSymbol: '\$', decimalSeparator: '.', thousandSeparator: ',', precision: 2);
  priceController.afterChange = (String masked, double raw) {
    //_price = raw;
  };
  return ListView (
    shrinkWrap: true,
    children: _buildCommonItems (context, widget) + [
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
          widget._sharesFrom = value;
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
          widget._sharesTo = value;
        }
      ),
    ],
  );
}

class AddTransaction extends StatelessWidget {
  final String portfolioId;
  final String portfolioName;

  AddTransaction ({@required this.portfolioName, @required this.portfolioId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column (
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              TransactionHeading (prefix: "Add", portfolioId: portfolioId, portfolioName: portfolioName),
              TransactionContents (portfolioId: portfolioId, portfolioName: portfolioName, trade: null),
          ]
        ),
      ),
    );
  }
}

class EditTransaction extends StatelessWidget {
  final String portfolioId;
  final String portfolioName;
  final Trade trade;

  EditTransaction ({@required this.portfolioName, @required this.portfolioId, @required this.trade});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column (
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              TransactionHeading (prefix: "Edit", portfolioId: portfolioId, portfolioName: portfolioName),
              TransactionContents (portfolioId: portfolioId, portfolioName: portfolioName, trade: trade),
          ]
        ),
      ),
    );
  }
}