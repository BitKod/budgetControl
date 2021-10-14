  import 'package:flutter/material.dart';
  final ThemeData myThemeDark = ThemeData(
    primarySwatch: MaterialColor(4280361249,{50: Color( 0xfff2f2f2 )
		, 100: Color( 0xffe6e6e6 )
		, 200: Color( 0xffcccccc )
		, 300: Color( 0xffb3b3b3 )
		, 400: Color( 0xff999999 )
		, 500: Color( 0xff808080 )
		, 600: Color( 0xff666666 )
		, 700: Color( 0xff4d4d4d )
		, 800: Color( 0xff333333 )
		, 900: Color( 0xff191919 )
		}),
    brightness: Brightness.dark,
    primaryColor: Color( 0xff212121 ),
    primaryColorBrightness: Brightness.dark,
    primaryColorLight: Color( 0xff9e9e9e ),
    primaryColorDark: Color( 0xff000000 ),
    accentColor: Color( 0xff64ffda ),
    accentColorBrightness: Brightness.light,
    canvasColor: Color( 0xff303030 ),
    scaffoldBackgroundColor: Color( 0xff303030 ),
    bottomAppBarColor: Color( 0xff424242 ),
    cardColor: Color( 0xff424242 ),
    dividerColor: Color( 0x1fffffff ),
    highlightColor: Color( 0x40cccccc ),
    splashColor: Color( 0x40cccccc ),
    selectedRowColor: Color( 0xfff5f5f5 ),
    unselectedWidgetColor: Color( 0xb3ffffff ),
    disabledColor: Color( 0x62ffffff ),
    buttonColor: Color( 0xff00897b ),
    toggleableActiveColor: Color( 0xff64ffda ),
    secondaryHeaderColor: Color( 0xff616161 ),
    textSelectionColor: Color( 0xff64ffda ),
    cursorColor: Color( 0xff4285f4 ),
    textSelectionHandleColor: Color( 0xff1de9b6 ),
    backgroundColor: Color( 0xff616161 ),
    dialogBackgroundColor: Color( 0xff424242 ),
    indicatorColor: Color( 0xff64ffda ),
    hintColor: Color( 0x80ffffff ),
    errorColor: Color( 0xffd32f2f ),
    buttonTheme: ButtonThemeData(
      textTheme: ButtonTextTheme.normal,
      minWidth: 88,
      height: 36,
      padding: EdgeInsets.only(top:0,bottom:0,left:16, right:16),
      shape:     RoundedRectangleBorder(
      side: BorderSide(color: Color( 0xff000000 ), width: 0, style: BorderStyle.none, ),
      borderRadius: BorderRadius.all(Radius.circular(2.0)),
    )
 ,
      alignedDropdown: false ,
      buttonColor: Color( 0xff00897b ),
      disabledColor: Color( 0x61ffffff ),
      highlightColor: Color( 0x29ffffff ),
      splashColor: Color( 0x1fffffff ),
      focusColor: Color( 0x1fffffff ),
      hoverColor: Color( 0x0affffff ),
      colorScheme: ColorScheme(
        primary: Color( 0xff009688 ),
        primaryVariant: Color( 0xff000000 ),
        secondary: Color( 0xff64ffda ),
        secondaryVariant: Color( 0xff00bfa5 ),
        surface: Color( 0xff424242 ),
        background: Color( 0xff616161 ),
        error: Color( 0xffd32f2f ),
        onPrimary: Color( 0xffffffff ),
        onSecondary: Color( 0xff000000 ),
        onSurface: Color( 0xffffffff ),
        onBackground: Color( 0xffffffff ),
        onError: Color( 0xff000000 ),
        brightness: Brightness.dark,
      ),
    ),

  );
