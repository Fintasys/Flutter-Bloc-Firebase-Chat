import 'package:flutter/material.dart';
import 'package:flutter_demo_chat/src/app.dart';
import 'package:flutter_demo_chat/src/services/auth_service.dart';
import 'package:flutter_demo_chat/src/services/auth_service_impl.dart';
import 'package:flutter_demo_chat/src/services/repository_service.dart';
import 'package:flutter_demo_chat/src/services/repository_service_impl.dart';
import 'package:get_it/get_it.dart';

GetIt locator = new GetIt();

void main() {
  locator.registerSingleton<RepositoryService>(new RepositoryServiceImpl());
  locator.registerSingleton<AuthService>(new AuthServiceImpl());
  runApp(MyApp());
}
