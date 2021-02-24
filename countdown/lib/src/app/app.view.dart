import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'components/musicplayer.dart';
import 'home/home.view.dart';

class AppWidget extends StatelessWidget {
  AppWidget() {
    // Application.api = API();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [const Locale('en', "US"), const Locale('vi', "VN")],
      title: 'Đếm',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        canvasColor: Colors.white,
        primaryColor: Colors.blue,
        accentColor: Colors.redAccent,
        fontFamily: "Quicksand",
      ),
      home: HomeWidget(),
      // add Modular to manage the routing system
      debugShowCheckedModeBanner: false,
    );
  }
}
