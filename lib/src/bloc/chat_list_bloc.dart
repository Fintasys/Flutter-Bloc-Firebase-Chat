import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_demo_chat/src/bloc/base_bloc.dart';
import 'package:flutter_demo_chat/src/model/user.dart';
import 'package:flutter_demo_chat/src/services/auth_service.dart';
import 'package:flutter_demo_chat/src/services/repository_service.dart';
import 'package:rxdart/rxdart.dart';

import '../../main.dart';

class ChatListBloc extends BaseBloc {
  var _repository;
  final _authService = locator<AuthService>();
  final _signedOut = BehaviorSubject<bool>();

  ChatListBloc([RepositoryService repoService]) {
    _repository = repoService ?? locator<RepositoryService>();
  }

  Observable<bool> get signedOut => _signedOut.stream;

  Stream<List<User>> chatList() =>
      _repository.getChatList().transform(documentToUserTransformer);

  static void convertDocumentToUser(
      QuerySnapshot snapShot, EventSink<List<User>> sink) {
    List<User> result = new List<User>();
    snapShot.documents.forEach((doc) => result.add(User(
        id: doc['id'],
        name: doc['name'],
        avatar: doc['avatar'],
        aboutMe: doc['aboutMe'])));
    sink.add(result);
  }

  StreamTransformer documentToUserTransformer =
      new StreamTransformer<QuerySnapshot, List<User>>.fromHandlers(
          handleData: convertDocumentToUser);

  void handleSignOut() async {
    setLoading(true);
    await _authService.handleUserSignOut();
    _signedOut.sink.add(true);
    setLoading(false);
  }

  void dispose() async {
    super.dispose();
    await _signedOut.drain();
    _signedOut.close();
  }
}
