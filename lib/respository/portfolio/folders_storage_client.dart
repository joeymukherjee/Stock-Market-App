import 'package:sembast/sembast.dart';
import 'package:sma/helpers/database_helper.dart';
import 'package:sma/models/portfolio/folder.dart';
import 'package:sma/models/storage/portfolio_folders_storage.dart';

class PortfolioFoldersStorageClient {

  final StoreRef<int, Map<String, dynamic>>  _store = intMapStoreFactory.store('portfolio_folder_storage_client');

  // Sembast Database.
  Future<Database> get _database async => await DatabaseManager.instance.database;

  // Gets all the folders stored.
  Future<List<PortfolioFolderModel>> fetch() async {

    final Finder finder = Finder(sortOrders: [SortOrder('order', true), SortOrder(Field.key, true)]);
    final response = await _store.find(await _database, finder: finder);
    return response
      .map((snapshot) => PortfolioFolderModel.fromStorage(snapshot.key, snapshot.value))
      .toList();
  }

  // Checks if a name already exists in the Database.
  Future<bool> nameExists({String name}) async {

    final finder = Finder(filter: Filter.matches('name', name));
    final response = await _store.findKey(await _database, finder: finder);

    return response != null;
  }

  // Saves a name in the database.
  Future<void> save({PortfolioFolderModel model}) async
  {
    PortfolioFoldersStorageModel storageModel = PortfolioFoldersStorageModel (name: model.name, exclude: model.exclude, order: model.order);
    final bool nameAlreadyExists = await nameExists(name: model.name);
    final record = model.key > 0 ? _store.record(model.key) : null;  // if the key is greater than 0, look for it!
    if (record == null && !nameAlreadyExists) {
      await _store.add(await _database, storageModel.toJson());
    } else {
      await _store.record(model.key).put(await _database, storageModel.toJson());
    }
  }

  // Deletes a name from the database.
  Future<void> delete({String name}) async
  {
    final finder = Finder(filter: Filter.matches('name', name));
    final response = await _store.findKey(await _database, finder: finder);
    final deleteFinder = Finder(filter: Filter.byKey(response));

    return await _store.delete(await _database, finder: deleteFinder);
  }

  // Gets a portfolio name based on portfolio id
  Future <String> getPortfolioName ({int portfolioId}) async {
    final finder = Finder(filter: Filter.equals('portfolioId', portfolioId));
    final response = await _store.findFirst(await _database, finder: finder);
    if (response == null) {
      return "Unknown!";
    } else {
      return response.value['name'];
    }
  }
}