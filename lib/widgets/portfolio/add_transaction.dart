import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sma/bloc/trade/trades_bloc.dart';
import 'package:sma/models/trade/trade.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:sma/shared/styles.dart';
import 'package:sma/shared/colors.dart';

class AddTransactionHeading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                child: Icon(Icons.arrow_back_ios),
                onTap: () => Navigator.pop(context)
              ),
              Expanded(child: Text('Add Transaction', style: kPortfolioHeaderTitle, textAlign: TextAlign.center)),
              GestureDetector(
                child: Icon(Icons.done),
                onTap: () => BlocProvider.of<TradesBloc>(context).add(CreatedTransaction())
              ),
            ],
          ),
        ],
      )
    );
  }
}

class AddTransactionContents extends StatefulWidget {
  final String portfolioName;
  AddTransactionContents ({@required this.portfolioName});

  @override
  _AddTransactionContentsState createState() => _AddTransactionContentsState();
}

class _AddTransactionContentsState extends State<AddTransactionContents> {
  String _portfolioName;
  final moneyEditController = MoneyMaskedTextController();
  String _ticker = '';
  DateTime _transactionDate;
  // These quantities are money
  double _price = 0.0;
  double _commission = 0.0;
  double _paid = 0.0;
  double _amountPerShare = 0.0;
  double _proceeds = 0.0;
  bool _didReinvest = true;
  // These quantities are strings since we have to parse them ourselves into doubles
  String _sharesTransacted = "0.0";
  String _sharesFrom = "0.0";
  String _sharesTo = "0.0";

  @override
  void initState () {
    _portfolioName = widget.portfolioName;
    super.initState();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _transactionDate == null ? DateTime.now() : _transactionDate,
        firstDate: DateTime(2000, 1),
        lastDate: DateTime.now());
    print ("Setting transaction date to " + _transactionDate.toString());
    if (picked != null && picked != _transactionDate)
      setState(() {
        _transactionDate = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TradesBloc, TradesState> (
      builder: (BuildContext context, TradesState state) {
        print ("AddTransaction: " + state.toString());
        return DefaultTabController(
          length: 4,
          child: Column (
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 35.0),
                child: TabBar(
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.greenAccent,
                    indicatorSize: TabBarIndicatorSize.label,
                    indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Colors.greenAccent),
                  tabs: [
                    Tab(child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(color: Colors.greenAccent, width: 1)),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text("Buy", textScaleFactor: 1.0),
                          ),
                        ),
                      ),
                    Tab(child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(color: Colors.greenAccent, width: 1)),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text("Sell", textScaleFactor: 1.0),
                          ),
                        ),
                      ),
                    Tab(child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(color: Colors.greenAccent, width: 1)),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text("Dividend", textScaleFactor: 1.0),
                          ),
                        ),
                      ),
                    Tab(child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(color: Colors.greenAccent, width: 1)),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text("Split", textScaleFactor: 1.0)
                          ),
                        ),
                      ),
                  ]
                ),
              ),
              Container(
                height: 670,
                child: TabBarView(
                  children: [
                    _buildBuyItems (context, this),          
                    _buildSellItems (context, this),
                    _buildDividendItems (context, this),
                    _buildSplitItems (context, this)
                  ]
                ),
              )
            ] 
          )
        );
      }
    );
  }
}

List<Widget> _buildCommonItems (context, widget) {
  print (widget);
  return [
    Row (
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text ("Portfolio"), Text (widget._portfolioName)]),
    TextFormField(
      initialValue: widget._ticker,
      textCapitalization: TextCapitalization.characters,
      decoration: InputDecoration (hintText: 'ticker name', labelText: "Ticker Name"),
      showCursor: true,
      onChanged: (String value) async { 
          widget.setState(() {
            widget._ticker = value;
          }
        );
      }
    ),
    Row (
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text ("Date"), 
        RaisedButton(
          color: Colors.greenAccent,
          onPressed: () { widget._selectDate(context); },
          child: Text (widget._transactionDate == null ? "Select Date" : DateFormat('yyyy-MM-dd').format(widget._transactionDate), style: TextStyle (color: Colors.black))
        )
      ]
    )
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
        showCursor: true,
        onChanged: (String value) async { 
            widget.setState(() {
            widget._sharesTransacted = double.parse(value);
          });
        }
      ),
      TextFormField(
        controller: MoneyMaskedTextController(initialValue: widget._price, decimalSeparator: '.', thousandSeparator: ','),
        decoration: InputDecoration (hintText: 'price paid', labelText: "Price"),
        showCursor: true,
        onChanged: (String value) async { 
            widget.setState(() {
              widget._price = double.parse(value);
            }
          );
        }
      ),
      TextFormField(
        controller: MoneyMaskedTextController(initialValue: widget._commission, decimalSeparator: '.', thousandSeparator: ','),
        decoration: InputDecoration (hintText: 'commission paid', labelText: "Commission"),
        showCursor: true,
        onChanged: (String value) async { 
            widget.setState(() {
              widget._commission = double.parse(value);
            }
          );
        }
      )
  ];
}

Widget _buildBuyItems (context, widget) {
  return Column (
    crossAxisAlignment: CrossAxisAlignment.start,
    children: _buildCommonItems(context, widget) + _buildCommonBuySellItems (context, widget) + [
      TextFormField(
        controller: MoneyMaskedTextController(initialValue: widget._paid, decimalSeparator: '.', thousandSeparator: ','),
        decoration: InputDecoration (hintText: 'amount paid', labelText: "Paid"),
        showCursor: true,
        onChanged: (String value) async { 
            widget.setState(() {
              widget._paid = widget._price * widget._sharesTransacted - widget._commission;
            }
          );
        }
      )
    ],
  );
}

Widget _buildSellItems (context, widget) {
  return Column (
    children: _buildCommonItems(context, widget) + _buildCommonBuySellItems (context, widget) + [
      TextFormField(
        controller: MoneyMaskedTextController(initialValue: widget._paid, decimalSeparator: '.', thousandSeparator: ','),
        decoration: InputDecoration (hintText: 'amount received', labelText: "Proceeds"),
        showCursor: true,
        onChanged: (String value) async { 
            widget.setState(() {
              widget._paid = widget._price * widget._sharesTransacted - widget._commission;
            }
          );
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
        controller: MoneyMaskedTextController(initialValue: widget._amountPerShare, decimalSeparator: '.', thousandSeparator: ','),
        decoration: InputDecoration (hintText: 'amount per share', labelText: "Amount per Share"),
        showCursor: true,
        onChanged: (String value) async { 
            widget.setState(() {
            widget._amountPerShare = double.parse(value);
          });
        }
      ),
      TextFormField(
        controller: MoneyMaskedTextController(initialValue: widget._proceeds, decimalSeparator: '.', thousandSeparator: ','),
        decoration: InputDecoration (hintText: 'dividend amount', labelText: "Dividend"),
        showCursor: true,
        onChanged: (String value) async { 
            widget.setState(() {
              widget._proceeds = double.parse(value);
            }
          );
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
  return Column (children: allChildren);
}

Widget _buildSplitItems (context, widget) {
  return Column (
    children: _buildCommonItems (context, widget) + [
      TextFormField(
        initialValue: widget._sharesTransacted,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp('[\\.0-9]*'))
        ],
        decoration: InputDecoration (hintText: 'number of shares', labelText: "Shares"),
        showCursor: true,
        onChanged: (String value) async { 
            widget.setState(() {
            widget._sharesTransacted = double.parse(value);
          });
        }
      ),
      TextFormField(
        controller: MoneyMaskedTextController(initialValue: widget._price, decimalSeparator: '.', thousandSeparator: ','),
        decoration: InputDecoration (hintText: 'price after split', labelText: "Price After"),
        showCursor: true,
        onChanged: (String value) async { 
            widget.setState(() {
              widget._price = double.parse(value);
            }
          );
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
        onChanged: (String value) async { 
            widget.setState(() {
            widget._sharesFrom = double.parse(value);
          });
        }
      ),
      TextFormField(
        initialValue: widget._sharesTo,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp('[\\.0-9]*'))
        ],
        decoration: InputDecoration (hintText: 'number of shares after split', labelText: "Shares To"),
        showCursor: true,
        onChanged: (String value) async { 
            widget.setState(() {
            widget._sharesTo = double.parse(value);
          });
        }
      ),
    ],
  );
}

class AddTransaction extends StatelessWidget {
  final int portfolioId;
  final String portfolioName;

  AddTransaction ({@required this.portfolioName, @required this.portfolioId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScaffoldBackground,
      body: SafeArea(
        child: ListView(
          // crossAxisAlignment: CrossAxisAlignment.start,
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
            AddTransactionHeading (),
            AddTransactionContents (portfolioName: portfolioName),
        ]),
      ),
    );
  }
}