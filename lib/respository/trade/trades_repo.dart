import 'package:sembast/sembast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sma/helpers/database_helper.dart';
import 'package:sma/models/trade/trade.dart';

abstract class TradesRepository {

  // Return all trades
  Future <List<Trade>> loadAllTrades();

  // Return all trades for a particular portfolio
  Future <List<Trade>> loadAllTradesForPortfolio(String portfolioId);

  // Return all trades for a particular portfolio
  Future <List<Trade>> loadAllTradesForTickerAndPortfolio(String ticker, String portfolioId);

  // Return all trades for a particular portfolio before a certain date
  // Used for the computation of dividends
  Future <List<Trade>> loadAllTradesForTickerAndPortfolioAndDate(String ticker, String portfolioId, DateTime since);

  // Saves a list of trades (these may have updated!)
  Future <void> saveTrades(List<Trade> trades);

  // Load a single trade based on an id
  Future <Trade> loadTrade(String id);

  // Inserts a new trade (must not exist)
  Future <void> addTrade(Trade trade);

  // Updates an existing trade (must already exist)
  Future <void> updateTrade(Trade trade);

  // Delete an existing trade(s)
  Future <void> deleteTrade(List<String> ids);

  // Delete a bunch of trades by ticker from a portfolio
  Future<void> deleteAllTradesByTickerAndPortfolio({String ticker, String portfolioId});
}

class SembastTradesRepository implements TradesRepository {
  static final SembastTradesRepository _singleton = SembastTradesRepository._internal();

  factory SembastTradesRepository() {
    return _singleton;
  }

  SembastTradesRepository._internal();

  final StoreRef<int, Map<String, dynamic>> _store = intMapStoreFactory.store('trades_repository');

  // Sembast Database.
  Future<Database> get _database async => await DatabaseManager.instance.database;

  Future<List<Trade>> loadAllTrades() async
  {
    final Finder finder = Finder(sortOrders: [SortOrder('transactionDate', true), SortOrder(Field.key, true)]);
    final response = await _store.find(await _database, finder: finder);
    return response
      .map((snapshot) => Trade.fromJson(snapshot.value))
      .toList();
  }

  Future<List<Trade>> loadAllTradesForPortfolio(String portfolioId) async
  {
    final Finder finder = Finder(filter: Filter.matches('portfolioId', portfolioId),
      sortOrders: [SortOrder('transactionDate', true), SortOrder(Field.key, true)]);
    final response = await _store.find(await _database, finder: finder);
    //print ("DB Contents:");
    //print (response);
    return response
      .map((snapshot) => Trade.fromJson(snapshot.value))
      .toList();
  }

  Future <List<Trade>> loadAllTradesForTickerAndPortfolio(String ticker, String portfolioId) async
  {
    final Finder finder = Finder(filter: Filter.equals('ticker', ticker) & Filter.equals('portfolioId', portfolioId),
      sortOrders: [SortOrder('transactionDate', true), SortOrder(Field.key, true)]);
    final response = await _store.find(await _database, finder: finder);
    return response
      .map((snapshot) => Trade.fromJson(snapshot.value))
      .toList();
  }

  Future <List<Trade>> loadAllTradesForTickerAndPortfolioAndDate(String ticker, String portfolioId, DateTime since) async {
    final Filter filter = Filter.and([
      Filter.equals('ticker', ticker),
      Filter.equals('portfolioId', portfolioId),
      Filter.lessThanOrEquals('transactionDate', since.toString())
    ]);
    final Finder finder = Finder(filter: filter, sortOrders: [SortOrder('transactionDate', true), SortOrder(Field.key, true)]);
    final response = await _store.find(await _database, finder: finder);
    return response
      .map((snapshot) => Trade.fromJson(snapshot.value))
      .toList();
  }

  Future <void> saveTrades(List<Trade> trades) async
  {
    trades.forEach((trade) async {
      final finder = Finder(filter: Filter.matches('id', trade.id));
      final response = await _store.findFirst(await _database, finder: finder);
      if (response == null) {
        addTrade(trade);
      } else {
        await _store.record(response.key).put(await _database, trade.toJson());
      }
    });
  }

  Future <Trade> loadTrade(String id) async
  {
    final finder = Finder(filter: Filter.matches('id', id));
    final response = await _store.findFirst(await _database, finder: finder);
    return Trade.fromJson(response.value);
  }

  // Inserts a new trade (must not exist)
  Future <void> addTrade(Trade trade) async
  {
    await _store.add(await _database, trade.toJson());
  }

  // Updates an existing trade (must already exist)
  Future <void> updateTrade(Trade trade) async
  {
    final finder = Finder(filter: Filter.matches('id', trade.id));
    final response = await _store.findFirst(await _database, finder: finder);
    await _store.record(response.key).put(await _database, trade.toJson());
  }

  // Delete an existing trade(s)
  Future <void> deleteTrade(List<String> ids) async
  {
    for (var idx = 0; idx < ids.length; idx++) {
      final finder = Finder(filter: Filter.matches('id', ids[idx]));
      final response = await _store.findFirst(await _database, finder: finder);
      await _store.record(response.key).delete(await _database);
    }
  }

  // Deletes all trades for a stock in a portfolio from the database.
  Future<void> deleteAllTradesByTickerAndPortfolio({String ticker, String portfolioId}) async
  {
    final finder = Finder(filter: Filter.equals('ticker', ticker) & Filter.equals('portfolioId', portfolioId));
    final response = await _store.find(await _database, finder: finder);
    response.forEach((element) async { await _store.record(element.key).delete(await _database); });
  }
}

class FirestoreTradesRepository implements TradesRepository {

  static final FirestoreTradesRepository _singleton = FirestoreTradesRepository._internal();
  static final CollectionReference collection = FirebaseFirestore.instance.collection('trades_repository');

  DateTime _lastUpdated;
  Source _source;

  factory FirestoreTradesRepository() {
    return _singleton;
  }

  FirestoreTradesRepository._internal();

  void _updateSource () {
    if (_lastUpdated == null || _lastUpdated.difference(DateTime.now()).inMinutes > 5) {
      _source = Source.server;
      _lastUpdated = DateTime.now();
    } else {
      _source = Source.cache;
    }
  }

  void _forceServerRead () {
    _lastUpdated = _lastUpdated.subtract(Duration (minutes: 5));
  }

  // Return all trades
  Future <List<Trade>> loadAllTrades() async {
    List<Trade> retVal = [];
    await collection
      .orderBy ('transactionDate', descending: false)
      .get(GetOptions (source: _source))
      .then((QuerySnapshot querySnapshot) => {
        querySnapshot.docs.forEach((trade) {
            retVal.add (Trade.fromJson(trade.data()));
        })
    });
    return retVal;
  }

  // Return all trades for a particular portfolio
  Future <List<Trade>> loadAllTradesForPortfolio(String portfolioId) async {
    List<Trade> retVal = [];
    _updateSource ();
    await collection
      .where('portfolioId', isEqualTo: portfolioId)
      .orderBy ('transactionDate', descending: false)
      .get(GetOptions (source: _source))
      .then((QuerySnapshot querySnapshot) => {
        querySnapshot.docs.forEach((trade) {
            retVal.add (Trade.fromJson(trade.data()));
        })
      });
    return retVal;
  }

  // Return all trades for a particular portfolio
  Future <List<Trade>> loadAllTradesForTickerAndPortfolio(String ticker, String portfolioId) async {
    List<Trade> retVal = [];
    _updateSource ();
    await collection
      .where('portfolioId', isEqualTo: portfolioId)
      .where('ticker', isEqualTo: ticker)
      .orderBy ('transactionDate', descending: false)
      .get(GetOptions (source: _source))
      .then((QuerySnapshot querySnapshot) => {
        querySnapshot.docs.forEach((trade) {
            retVal.add (Trade.fromJson(trade.data()));
        })
    });
    return retVal;
  }

  // Return all trades for a particular portfolio before a certain date
  Future <List<Trade>> loadAllTradesForTickerAndPortfolioAndDate(String ticker, String portfolioId, DateTime since) async {
    List<Trade> retVal = [];
    _updateSource ();
    await collection
      .where('portfolioId', isEqualTo: portfolioId)
      .where('ticker', isEqualTo: ticker)
      .where('transactionDate', isGreaterThanOrEqualTo: since)
      .orderBy ('transactionDate', descending: false)
      .get(GetOptions (source: _source))
      .then((QuerySnapshot querySnapshot) => {
        querySnapshot.docs.forEach((trade) {
            retVal.add (Trade.fromJson(trade.data()));
        })
    });
    return retVal;
  }

  // Saves a list of trades (these may have updated!)
  Future <void> saveTrades(List<Trade> trades) async {
    trades.forEach((trade) {updateTrade (trade); });
    _forceServerRead ();
  }

  // Load a single trade based on an id
  Future <Trade> loadTrade(String id) async {
    List<Trade> retVal = [];
    _updateSource ();
    await collection
      .where('id', isEqualTo: id)
      .get(GetOptions (source: _source))
      .then((QuerySnapshot querySnapshot) => {
        querySnapshot.docs.forEach((trade) {
            retVal.add (Trade.fromJson(trade.data()));
        })
    });
    assert (retVal.length == 1);
    return retVal [0];
  }

  // Inserts a new trade (must not exist)
  Future <void> addTrade(Trade trade) async {
    collection
      .add(trade.toJson ())
      .then((value) => print("Trade added!"))
      .catchError((error) => print ("Failed to save trade: $error"));
  }

  // Updates an existing trade (must already exist)
  Future <void> updateTrade(Trade trade) async {
    collection
    .doc(trade.id)
    .set(trade.toJson ())
    .then((value) => print("Trade updated!"))
    .catchError((error) => print ("Failed to update trade: $error"));
  }

  // Delete an existing trade(s)
  Future <void> deleteTrade(List<String> ids) async {
    ids.forEach((id) {
      collection
      .doc(id)
      .delete()
      .then((value) => print("Trade deleted!"))
      .catchError((error) => print ("Failed to delete trade: $error"));
    });

  }

  // Delete a bunch of trades by ticker from a portfolio
  Future<void> deleteAllTradesByTickerAndPortfolio({String ticker, String portfolioId}) async {
    await collection
      .where('portfolioId', isEqualTo: portfolioId)
      .where('ticker', isEqualTo: ticker)
      .get(GetOptions (source: Source.server))  // always delete on server!
      .then((QuerySnapshot querySnapshot) => {
        querySnapshot.docs.forEach((trade) {
            deleteTrade([trade.id]);
        })
    });
    _forceServerRead();
  }
}

final TradesRepository globalTradesDatabase = FirestoreTradesRepository ();