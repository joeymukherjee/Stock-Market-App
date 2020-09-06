import 'package:sembast/sembast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sma/helpers/database_helper.dart';
import 'package:sma/models/portfolio/folder.dart';
import 'package:sma/models/trade/trade.dart';
import 'package:sma/respository/trade/trades_repo.dart';

abstract class PortfolioFoldersRepository {
  Future<List<PortfolioFolderModel>> getAllPortfolioFolders();

  // Gets a portfolio name based on portfolio id, which is also the database key
  Future <PortfolioFolderModel> getPortfolioFolder({String portfolioId});

  // Saves a portfolio folder in the database.
  Future<void> savePortfolioFolder({PortfolioFolderModel model});

  // Deletes a folder from the database.
  Future<void> deletePortfolioFolder({String id});
}

class SembastPortfolioFoldersRepository extends PortfolioFoldersRepository {

// This has a singleton built in based in database_helper.

  final StoreRef<int, Map<String, dynamic>>  _store = intMapStoreFactory.store('portfolio_folder_storage_client');

  // Sembast Database.
  Future<Database> get _database async => await DatabaseManager.instance.database;

  // Gets all the folders stored.
  Future<List<PortfolioFolderModel>> getAllPortfolioFolders() async {

    final Finder finder = Finder(sortOrders: [SortOrder('order', true), SortOrder(Field.key, true)]);
    final response = await _store.find(await _database, finder: finder);
    return response
      .map((snapshot) => PortfolioFolderModel.fromStorage(snapshot.value))
      .toList();
  }

  // Checks if a name already exists in the Database.
  Future<bool> _nameExists({String name}) async {

    final finder = Finder(filter: Filter.matches('name', name));
    final response = await _store.findKey(await _database, finder: finder);

    return response != null;
  }

  // Saves a folder in the database.
  Future<void> savePortfolioFolder({PortfolioFolderModel model}) async
  {
    final bool nameAlreadyExists = await _nameExists(name: model.name);
    final finder = Finder(filter: Filter.matches('id', model.id));
    final response = await _store.findKey(await _database, finder: finder);

    if (response == null && !nameAlreadyExists) {
      await _store.add(await _database, model.toJson());
    } else {
      await _store.record(response).put(await _database, model.toJson());
    }
  }

  // Deletes a name from the database.
  Future<void> deletePortfolioFolder({String id}) async
  {
    final finder = Finder(filter: Filter.matches('id', id));
    final response = await _store.findKey(await _database, finder: finder);
    await _store.record(response).delete(await _database);
  }

  // Gets a portfolio name based on portfolio id, which is also the database key
  Future <PortfolioFolderModel> getPortfolioFolder({String portfolioId}) async {
    final finder = Finder(filter: Filter.matches('id', portfolioId));
    final key = await _store.findKey(await _database, finder: finder);
    final response = await _store.record(key).get(await _database);
    if (response == null) {
      return null;
    } else {
      return PortfolioFolderModel.fromStorage(response);
    }
  }
}

class FirestorePortfolioFoldersRepository extends PortfolioFoldersRepository {
  final CollectionReference collection = FirebaseFirestore.instance.collection('portfolio_folders_repository');

  Future<List<PortfolioFolderModel>> getAllPortfolioFolders() async {
    List<PortfolioFolderModel> retVal = [];
    await collection
      .orderBy ('order', descending: true)
      .get()
      .then((QuerySnapshot querySnapshot) => {
        querySnapshot.docs.forEach((folder) {
            retVal.add (PortfolioFolderModel.fromStorage(folder.data()));
        })
    });
    return retVal;
  }

  // Gets a portfolio based on portfolio id, which is also the database key
  Future <PortfolioFolderModel> getPortfolioFolder({String portfolioId}) async {
    List<PortfolioFolderModel> retVal = [];
    await collection
      .where('id', isEqualTo: portfolioId)
      .orderBy ('order', descending: true)
      .get()
      .then((QuerySnapshot querySnapshot) => {
        querySnapshot.docs.forEach((folder) {
            retVal.add (PortfolioFolderModel.fromStorage(folder.data()));
        })
    });
    assert (retVal.length == 1);
    return retVal [0];
  }

  // Saves a portfolio folder in the database.
  Future<void> savePortfolioFolder({PortfolioFolderModel model}) async {
    collection
    .doc(model.id == '' ? null : model.id)
    .set(model.toJson ())
    .then((value) => print("Folder updated!"))
    .catchError((error) => print ("Failed to update folder: $error"));
  }

  // Deletes a folder from the database by name
  Future<void> deletePortfolioFolder({String id}) async {
    collection
      .where('id', isEqualTo: id)
      .get()
      .then((QuerySnapshot querySnapshot) => {
        querySnapshot.docs.forEach((folder) async {
          List<Trade> trades = await globalTradesDatabase.loadAllTradesForPortfolio(id);
          trades.forEach((trade) { globalTradesDatabase.deleteTrade([trade.id]); });
          folder.reference.delete();
          print("Folder deleted!");
        }
      )})
      .catchError((error) => print ("Failed to delete folder: $error"));
  }
}

final PortfolioFoldersRepository globalPortfolioFoldersDatabase = FirestorePortfolioFoldersRepository ();