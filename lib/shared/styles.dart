import 'package:flutter/material.dart';

/// All for my theming stuff
const Color primaryColorLight = Color(0xff40b3fb);
const Color backgroundColorLight = Color(0xffF8FCFF);
const Color textColorLight = Color(0xff094067);
const Color primaryColorDark = Color(0xffF8FCFF);
const Color backgroundColorDark = Color(0XFF0e0e0e);
const Color textColorDark = Color(0xFFDEDEDE);

OutlineInputBorder inputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.circular(15),
  borderSide: BorderSide(color: Colors.transparent),
);

ThemeData lightMode = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: backgroundColorLight,
    accentColor: Color(0xFFDEDEDE),
    ////// Text Theme //////
    fontFamily: 'Poppins',
    textTheme: TextTheme(
      ////// Title Page
        bodyText2: TextStyle(color: primaryColorLight),
        ////// Dialog subtitle and text field and card title
        subtitle1: TextStyle(color: textColorLight),
        ////// Body of the card note
        caption: TextStyle(color: textColorLight)),
    ////// Icon
    highlightColor: Color(0xFF00C1FF), // primaryColorLight.withOpacity(0.05),
    splashColor: Color(0xFF2E2E33), // primaryColorLight.withOpacity(0.05),
    iconTheme: IconThemeData(color: primaryColorLight),
    primaryIconTheme: IconThemeData(color: Color(0xFF3A3A3A)),
    ////// Card
    cardTheme: CardTheme(shadowColor: Color(0xff73c7fc).withOpacity(0.3),color: Color(0xffFAFDFF)),
    tabBarTheme: TabBarTheme(labelColor: Colors.white, unselectedLabelColor: Colors.black),
//    dialogBackgroundColor: Color(0xFF332F39),
    ////// FAB //////
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      foregroundColor: backgroundColorLight,
      splashColor: Color(0xFF00C1FF),
      backgroundColor: primaryColorLight,
    ),
    ////// Input Decoration
    cursorColor: primaryColorLight,
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: TextStyle(color: Colors.black45,fontSize: 20),
      filled: true,
      fillColor: Color(0xFFF4F8FB),
      enabledBorder: inputBorder,
      focusedBorder: inputBorder,
    ),
  );


  ThemeData darkMode = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundColorDark,
    primaryColor: Color(0xFF2E2E33),
    accentColor: Color(0XFF181818),
    secondaryHeaderColor: Color(0XFF898989),
    ////// Text Theme //////
    fontFamily: 'Poppins',
    textTheme: TextTheme(
        ////// Title Page
        bodyText2: TextStyle(color: Color(0XFFc2c2c2)),
        ////// Dialog subtitle and text field and card title
        subtitle1: TextStyle(color: textColorDark),
        ////// Body of the card note
        caption: TextStyle(color: textColorDark)),
    ////// Icon //////
    highlightColor: Color(0XFF757575), // Colors.white.withOpacity(0.05),
    splashColor: Color(0XFFcdcdcd), // Colors.white.withOpacity(0.05),
    iconTheme: IconThemeData(color: primaryColorDark),
    primaryIconTheme: IconThemeData(color: textColorDark),
    ////// Card //////
    cardTheme: CardTheme(shadowColor: Color(0xFF36323B),color: Color(0xFF302E3F)),
    dialogBackgroundColor: Color(0xFF302E3F),
    tabBarTheme: TabBarTheme(labelColor: Colors.white, unselectedLabelColor: Colors.white),
    ////// FAB //////
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      foregroundColor: textColorDark,
      splashColor: Color(0xFF3EC0DA),
      backgroundColor: primaryColorDark,
    ),
    ////// Input Decoration //////
    cursorColor: primaryColorDark,
    inputDecorationTheme: InputDecorationTheme(
      //hintStyle: TextStyle(color: Colors.white24,fontSize: 20),
      //filled: false,
      //fillColor: Color(0xFF313142),
      //enabledBorder: inputBorder,
      //focusedBorder: inputBorder,
    ),
  );
///////////////////////////////////

/// This is the common border radius of all the containers in the app.
const kStandardBorder = const BorderRadius.all(Radius.circular(6));

/// This border is slightly more sharp than the standard border.
const kSharpBorder = const BorderRadius.all(Radius.circular(2));

/// This is the common text styling for a subtile. 
const kCompanyNameHeading = const TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w800
);

// Common header for portfolio section
const kPortfolioHeaderTitle = const TextStyle(
  fontSize: 28,
  fontWeight: FontWeight.bold
);

const kStockTickerSymbol = const TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.bold
);

const kStockPriceStyle = const TextStyle(
  fontWeight: FontWeight.bold
);