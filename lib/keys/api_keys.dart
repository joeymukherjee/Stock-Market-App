// You will need to get your own keys from each of these 
// Create a file called .env in your home directory (above lib).
// It will have lines like "kSentryDomainNameSystem=sf8sfsf9sfd" without quotes or spaces
// Have a separate line for all of them

import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Sentry DNS is used to track errors. It is beeing used at [SentryHelper].
/// To get your DNS, go to: https://sentry.io/. 
/// Create a project and follow these steps: https://forum.sentry.io/t/where-can-i-find-my-dsn/4877
final String kSentryDomainNameSystem = DotEnv().env ['kSentryDomainNameSystem'];

/// The Alpha Vantage API is used to power the Search Section.
/// It is used at [SearchClient]. 
/// To get your own API key go to: https://www.alphavantage.co.
final String kAlphaVantageKey = DotEnv().env ['kAlphaVantageKey'];

/*
/// The Finnhub Stock API is used to power the news section in the [ProfileSection] page.
/// It is used at [ProfileClient]. 
/// To get your own API key go to: https://finnhub.io.
// JM - we are not using this anymore
final String kFinnhubKey = DotEnv().env ['kFinnhubKey'];
*/

/// The News API is used to power the news section.
/// It is used at [NewsClient]. 
/// To get your own API key go to: https://newsapi.org.
final String kNewsKey = DotEnv().env ['kNewsKey'];

/// Financial Modeling Prep API is used to power the Home, U.S Market and Profile Section.
/// Now an API key is required which means that we won't be able to make infinite requests. :(
/// To get your own API key go to: https://financialmodelingprep.com/developer/docs/
/// JM - This is no longer used.  The free account only gives you 250
final String kFinancialModelingPrepApi = DotEnv().env ['kFinancialModelingPrepApi'];

/// IEX Cloud API Key
/// Get an API key here: https://iexcloud.io/s/ae6531cc
const bool useIEXCloudSandbox = true;
final String kIEXCloudBaseUrl = 'cloud.iexapis.com';  // real
final String kIEXCloudKey = DotEnv().env ['kIEXCloudKey'];
final String kIEXCloudSandboxBaseUrl = 'sandbox.iexapis.com';  // sandbox
final String kIEXCloudSandboxKey = DotEnv().env ['kIEXCloudSandboxKey'];
