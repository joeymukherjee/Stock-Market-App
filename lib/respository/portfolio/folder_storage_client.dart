import 'package:sembast/sembast.dart';
import 'package:sma/helpers/database_helper.dart';
import 'package:sma/models/portfolio/folder.dart';
import 'package:sma/models/storage/portfolio_folder_storage.dart';

class PortfolioFolderStorageClient {

  final StoreRef<int, Map<String, dynamic>>  _store = intMapStoreFactory.store('portfolio_folder_storage_client');

  // Sembast Database.
  Future<Database> get _database async => await DatabaseManager.instance.database;

  // Gets all the names stored.
  Future<List<PortfolioFolderStorageModel>> fetch() async {

    final Finder finder = Finder(sortOrders: [SortOrder(Field.key, false)]);
    final response = await _store.find(await _database, finder: finder);

    return response
    .map((snapshot) => PortfolioFolderStorageModel.fromJson(snapshot.value))
    .toList();
  }

  // Fetch all the stuff for a single folder

  Future<PortfolioFolderModel> fetchPortfolio(PortfolioFolderStorageModel storageModel) async {
    print ("fetchPortfolio");
    return null;
  }

  // Checks if a name already exists in the Database.
  Future<bool> nameExists({String name}) async {

    final finder = Finder(filter: Filter.matches('name', name));
    final response = await _store.findKey(await _database, finder: finder);

    return response != null;
  }

  // Saves a name in the database.
  Future<void> save({PortfolioFolderStorageModel storageModel}) async {
    
    final bool isSaved = await nameExists(name: storageModel.name);

    if (!isSaved) {
      await _store.add(await _database, storageModel.toJson());
    }
  }

  // Deletes a name from the database.
  Future<void> delete({String name}) async {

    final finder = Finder(filter: Filter.matches('name', name));
    final response = await _store.findKey(await _database, finder: finder);
    final deleteFinder = Finder(filter: Filter.byKey(response));

    return await _store.delete(await _database, finder: deleteFinder);
  }

}