import 'package:sembast/sembast.dart';
import 'package:sma/helpers/database_helper.dart';
import 'package:sma/models/trade/trade.dart';

abstract class TradesRepository {

  // Return all trades
  Future <List<Trade>> loadAllTrades ();

  // Return all trades for a particular portfolio
  Future <List<Trade>> loadAllTradesForPortfolio (int portfolioId);

  // Saves a list of trades (these may have updated!)
  Future <void> saveTrades (List<Trade> trades);

  // Load a single trade based on an id
  Future <Trade> loadTrade (String id);

  // Inserts a new trade (must not exist)
  Future <void> addTrade (Trade trade);

  // Updates an existing trade (must already exist)
  Future <void> updateTrade (Trade trade);

  // Delete an existing trade(s)
  Future <void> deleteTrade (List<String> ids);
}

class SembastTradesRepository implements TradesRepository {
  final StoreRef<int, Map<String, dynamic>> _store = intMapStoreFactory.store('trades_repository');

  // Sembast Database.
  Future<Database> get _database async => await DatabaseManager.instance.database;

  Future<List<Trade>> loadAllTrades () async
  {
    final Finder finder = Finder(sortOrders: [SortOrder('transactionDate', true), SortOrder(Field.key, true)]);
    final response = await _store.find(await _database, finder: finder);
    return response
      .map((snapshot) => Trade.fromJson(snapshot.value))
      .toList();
  }

  Future<List<Trade>> loadAllTradesForPortfolio (int portfolioId) async
  {
    print ("portfolioId to find: " + portfolioId.toString());
    //final Finder finder = Finder(filter: Filter.matches('portfolioId', portfolioId.toString())); // , sortOrders: [SortOrder('transactionDate', true), SortOrder(Field.key, true)]);
    // TODO - remove after we fix database
    final Finder finder = Finder(filter: Filter.equals('ticker','AAPL'), sortOrders: [SortOrder ('ticker', true), SortOrder('transactionDate', true), SortOrder(Field.key, true)]);
    final response = await _store.find(await _database, finder: finder);
    print ("DB Contents:");
    print (response);
    return response
      .map((snapshot) => Trade.fromJson(snapshot.value))
      .toList();
  }

  Future <void> saveTrades (List<Trade> trades) async
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

  Future <Trade> loadTrade (String id) async
  {
    final finder = Finder(filter: Filter.matches('id', id));
    final response = await _store.findFirst(await _database, finder: finder);
    return Trade.fromJson(response.value);
  }

  // Inserts a new trade (must not exist)
  Future <void> addTrade (Trade trade) async
  {
    await _store.add(await _database, trade.toJson());
  }

  // Updates an existing trade (must already exist)
  Future <void> updateTrade (Trade trade) async
  {
    final finder = Finder(filter: Filter.matches('id', trade.id));
    final response = await _store.findFirst(await _database, finder: finder);
    await _store.record(response.key).put(await _database, trade.toJson());
  }

  // Delete an existing trade(s)
  Future <void> deleteTrade (List<String> ids) async
  {
    ids.forEach((id) async {
      final finder = Finder(filter: Filter.matches('id', id));
      final response = await _store.findFirst(await _database, finder: finder);
      final deleteFinder = Finder(filter: Filter.byKey(response));
      await _store.delete(await _database, finder: deleteFinder);
    }); 
  }
}