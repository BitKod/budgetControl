import 'package:flutter/material.dart';

class AppConstants {
  // declaring constants
  static AppConstants _instance = AppConstants._init();
  static AppConstants get instance => _instance;
  AppConstants._init();

//getting Currency Info
  static const FIXER_API = "http://data.fixer.io/api/";
  static const FIXER_KEY = "?access_key=c510501f50de16aed780141646f29387";
  static const FIXER_GET_CURRENCY = "http://data.fixer.io/api/latest?access_key=c510501f50de16aed780141646f29387&symbols=USD,TRY&format=1";

//setting language of the app
  static const SUPPORTED_LOCALE = [
    AppConstants.EN_LOCALE,
    AppConstants.TR_LOCALE
  ]; 
  static const TR_LOCALE=Locale("tr","TR");
  static const EN_LOCALE=Locale("en","US");
  static const LANG_PATH="assets/lang";

  // for silverGrids
  var sliverGridDelegateWithFixedCrossAxisCount =
      SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    mainAxisSpacing: 10.0,
    childAspectRatio: 1 / 2,
    crossAxisSpacing: 10.0,
  );

  // for input decorations to use in textfields
  InputDecoration textInputDecoration = InputDecoration(
    contentPadding: EdgeInsets.all(5.0),
    labelText: '',
    filled: true,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: Colors.cyan,
        width: 2.0,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: Colors.cyanAccent,
        width: 2.0,
      ),
    ),
  );

  // for input cards
  Card inputCard = Card(
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(width: 5, color: Colors.cyan)),
    child: TextFormField(
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(5.0),
        labelText: '',
        hintText: '',
        filled: true,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(10), topRight: Radius.circular(10)),
          borderSide: BorderSide(
            color: Colors.cyan,
            width: 2.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.cyanAccent,
            width: 2.0,
          ),
        ),
      ),
    ),
  );
}
