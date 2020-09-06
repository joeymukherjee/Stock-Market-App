import 'dart:io';
import 'dart:convert';
import 'package:meta/meta.dart';
import 'package:sma/models/trade/trade.dart';
import 'package:csv/csv.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sma/bloc/trade/trades_bloc.dart';

// This class is meant to help us import trades into our format
// The idea is this is an abstract class that has all the things 
// we need to go from their ASCII or API format to what we need

abstract class ImportHelper {
  void getAllTrades ();
}

class ReadRobinhoodCSV extends ImportHelper {
  final BuildContext context;
  final String filename;
  final String portfolioId;
  final List<String> columns = ['symbol', 'name', 'side', 'type', 'quantity', 'price', 'amount', 'date', 'fees'];

  ReadRobinhoodCSV({@required this.context, @required File file, @required this.portfolioId}) : this.filename = file.path;
  ReadRobinhoodCSV.fromFilename ({@required this.context, @required this.filename}) : portfolioId = '';

// Given a CSV line, convert to a trade
  Trade parseLine (List<dynamic> lineParts) {
    Map <String, dynamic> lineMap = lineParts.asMap().map ((index, value) => MapEntry(columns [index], value));
    TransactionType type;
    Trade trade;
    if (lineMap ['side'] == 'buy') {
      type = TransactionType.purchase;
      trade = Common.withId(id: null, ticker: lineMap ['symbol'], portfolioId: this.portfolioId,
                            type: type, transactionDate: DateTime.parse(lineMap ['date']),
                            price: lineMap ['price'].toDouble(),
                            sharesTransacted: lineMap['quantity'].toDouble(),
                            commission: lineMap['fees'].toDouble());
    } else if (lineMap ['side'] == 'sell') {
      type = TransactionType.sell;
      trade = Common.withId(id: null, ticker: lineMap ['symbol'], portfolioId: this.portfolioId,
                            type: type, transactionDate: DateTime.parse(lineMap ['date']),
                            price: lineMap ['price'].toDouble(),
                            sharesTransacted: lineMap['quantity'].toDouble(),
                            commission: lineMap['fees'].toDouble());
    } else if (lineMap ['type'] == 'dividend') {
      type = TransactionType.dividend;
      trade = Dividend.withId(id: null, ticker: lineMap ['symbol'], portfolioId: this.portfolioId,
                            transactionDate: DateTime.parse(lineMap ['date']),
                            numberOfShares: lineMap['quantity'].toDouble(),
                            amountPerShare: lineMap ['price'].toDouble(),
                            commission: lineMap['fees'].toDouble(),
                            didReinvest: false, price: 0.0, sharesTransacted: 0.0,  // looks like DRIP might be another buy order?
                            );
    }
    return trade;
  }

  void getAllTradesFromFile (File csvFile) async {
    List<Trade> trades = [];
    csvFile.openRead()
      .transform(utf8.decoder)
      .transform(CsvToListConverter())
      .listen((lineParts) { 
        Trade trade = parseLine (lineParts);
        // print (trade);
        if (trade != null) trades.add(trade);
      }, 
      onDone: () { 
        print ('$filename has been converted!'); 
        BlocProvider
        .of<TradesBloc>(context)
        .add(MergeMultipleTrades(portfolioId: portfolioId, trades: trades));
      },
      onError: (e) { print (e.toString()); }
    );
  }

  void getAllTrades () async {
    final csvFile = File (filename);
    getAllTradesFromFile(csvFile);
  }
}