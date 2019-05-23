import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_demo_chat/src/model/chat_info.dart';
import 'package:flutter_demo_chat/src/model/user.dart';

class FireStoreProvider {
  Firestore _firestore = Firestore.instance;

  Future<int> authenticateUser() async {
    final QuerySnapshot result =
        await _firestore.collection("users").getDocuments();
    final List<DocumentSnapshot> docs = result.documents;
    if (docs.length == 0) {
      return 0;
    } else {
      return 1;
    }
  }

  Future<void> registerUser(User user) async {
    _firestore
        .collection('users')
        .document(user.id)
        .setData({'id': user.id, 'name': user.name, 'avatar': user.avatar});
  }

  Future<User> updateUser(User user) async {
    return _firestore.collection("users").document(user.id).updateData({
      'name': user.name,
      'avatar': user.avatar,
      'aboutMe': user.aboutMe
    }).then((_) {
      return getUser(user.id);
    });
  }

  Future<User> getUser(String userId) async {
    var result = await _firestore
        .collection('users')
        .where('id', isEqualTo: userId)
        .getDocuments();
    List<DocumentSnapshot> documents = result.documents;
    if (documents.length == 1) {
      return User(
          id: documents[0]['id'],
          name: documents[0]['name'],
          avatar: documents[0]['avatar'],
          aboutMe: documents[0]['aboutMe']);
    }
    return null;
  }

  Stream<QuerySnapshot> getChatList() {
    return _firestore.collection('users').snapshots();
  }

  Stream<QuerySnapshot> getChatHistory(ChatInfo chatInfo) {
    return _firestore
        .collection('messages')
        .document(chatInfo?.getGroupChatId())
        .collection(chatInfo?.getGroupChatId())
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots();
  }

  Future<void> sendChatMsg(ChatInfo chatInfo, String content, int type) async {
    var chatReference = Firestore.instance
        .collection('messages')
        .document(chatInfo.getGroupChatId())
        .collection(chatInfo.getGroupChatId())
        .document(DateTime.now().millisecondsSinceEpoch.toString());

    return _firestore.runTransaction((transaction) async {
      await transaction.set(
        chatReference,
        {
          'idFrom': chatInfo.fromUser.id,
          'idTo': chatInfo.toUser.id,
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          'content': content,
          'type': type
        },
      );
    });
  }

  Future<void> setChatLastMsg(ChatInfo chatInfo, String lastContent) async {
    var chatReference = Firestore.instance
        .collection('messages')
        .document(chatInfo.getGroupChatId());

    return _firestore.runTransaction((transaction) async {
      await transaction.set(
        chatReference,
        {
          'lastMessage': lastContent,
        },
      );
    });
  }
}
