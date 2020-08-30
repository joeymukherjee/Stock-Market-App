import 'package:sembast/sembast.dart';
import 'package:sma/helpers/database_helper.dart';
import 'package:sma/models/trade/company.dart';

abstract class CompaniesRepository {

// Saves a list of companies (these may have updated!)
  Future <void> saveCompanies(List<Company> companies);

// Load a single company based on an ticker
  Future <Company> loadCompany(String ticker);
}

class LocalCompaniesRepository implements CompaniesRepository {
  final StoreRef<int, Map<String, dynamic>> _store = intMapStoreFactory.store('companies_repository');

  // Sembast Database.
  Future<Database> get _database async => await DatabaseManager.instance.database;

  Future <Company> loadCompany(String ticker) async
  {
    final finder = Finder(filter: Filter.matches('ticker', ticker));
    final response = await _store.findFirst(await _database, finder: finder);
    if (response != null) {
      return Company.fromJson(response.value);
    } else {
      return null;
    }
  }

  Future <void> saveCompanies(List<Company> companies) async
  {
    companies.forEach((company) async {
      final finder = Finder(filter: Filter.matches('ticker', company.ticker));
      final response = await _store.findFirst(await _database, finder: finder);
      if (response == null) {
        addTrade(company);
      } else {
        await _store.record(response.key).put(await _database, company.toJson());
      }
    });
  }

  // Inserts a new company (must not exist)
  Future <void> addTrade(Company company) async
  {
    await _store.add(await _database, company.toJson());
  }

}
