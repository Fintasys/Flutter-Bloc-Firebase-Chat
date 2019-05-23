import 'package:flutter/material.dart';
import 'package:flutter_bloc_firebase_chat/src/routing/router.dart';
import 'package:flutter_bloc_firebase_chat/src/services/auth_service.dart';
import 'package:flutter_bloc_firebase_chat/src/utils/color_const.dart';
import 'package:flutter_bloc_firebase_chat/src/utils/string_const.dart';

import '../main.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          primarySwatch: primarySwatch,
          primaryColor: primaryColor,
          accentColor: accentColor,
          canvasColor: canvasColor,
        ),
        initialRoute: StringConstant.route_sign_in,
        onGenerateRoute: Router.generateRoute);
  }

  @override
  void dispose() {
    locator<AuthService>().dispose();
    super.dispose();
  }
}
