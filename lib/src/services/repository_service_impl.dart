import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_demo_chat/src/model/chat_info.dart';
import 'package:flutter_demo_chat/src/model/user.dart';
import 'package:flutter_demo_chat/src/resources/fireauth_provider.dart';
import 'package:flutter_demo_chat/src/resources/firestorage_provider.dart';
import 'package:flutter_demo_chat/src/resources/firestore_provider.dart';
import 'package:flutter_demo_chat/src/services/repository_service.dart';

class RepositoryServiceImpl implements RepositoryService {
  final _fireAuthProvider = FireAuthProvider();
  final _fireStoreProvider = FireStoreProvider();
  final _fireStorageProvider = FireStorageProvider();

  Future<FirebaseUser> signInWithCredential(AuthCredential credential) =>
      _fireAuthProvider.signInWithCredential(credential);

  Future<void> signOut() => _fireAuthProvider.signOut();

  Future<void> registerUser(User user) => _fireStoreProvider.registerUser(user);

  Stream<QuerySnapshot> getChatList() => _fireStoreProvider.getChatList();

  Stream<QuerySnapshot> getChatHistory(ChatInfo chatInfo) =>
      _fireStoreProvider.getChatHistory(chatInfo);

  Future<void> sendChatMsg(ChatInfo chatInfo, String content, int type) {
    var lastContent = content;
    if (type == 1) {
      lastContent = "Image was sent";
    } else if (type == 2) {
      lastContent = "Sticker was sent";
    }

    return _fireStoreProvider.sendChatMsg(chatInfo, content, type).then((_) {
      _fireStoreProvider.setChatLastMsg(chatInfo, lastContent);
    });
  }

  Future<User> getUser(String userId) {
    return _fireStoreProvider.getUser(userId);
  }

  Future<User> updateUser(User user) {
    return _fireStoreProvider.updateUser(user);
  }

  Future<StorageTaskSnapshot> uploadUserAvatar(String userId, File image) {
    return _fireStorageProvider.uploadUserAvatar(userId, image);
  }
}
