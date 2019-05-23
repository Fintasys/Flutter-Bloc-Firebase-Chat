import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc_firebase_chat/src/model/chat_info.dart';
import 'package:flutter_bloc_firebase_chat/src/model/user.dart';

abstract class RepositoryService {
  Future<FirebaseUser> signInWithCredential(AuthCredential credential);

  Future<void> signOut();

  Future<void> registerUser(User user);

  Future<User> getUser(String userId);

  Future<User> updateUser(User user);

  Future<StorageTaskSnapshot> uploadUserAvatar(String userId, File image);

  Stream<QuerySnapshot> getChatList();

  Stream<QuerySnapshot> getChatHistory(ChatInfo chatInfo);

  Future<void> sendChatMsg(ChatInfo chatInfo, String content, int type);
}
