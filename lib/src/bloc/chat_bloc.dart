import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc_firebase_chat/src/bloc/base_bloc.dart';
import 'package:flutter_bloc_firebase_chat/src/model/chat_info.dart';
import 'package:flutter_bloc_firebase_chat/src/services/repository_service.dart';
import 'package:flutter_bloc_firebase_chat/src/utils/string_const.dart';
import 'package:flutter_bloc_firebase_chat/src/widgets/helper/UiAction.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';

enum ACTIONS {
  clearTextEditingController,
  error,
  showToast,
  animateListScrollController
}

class ChatBloc extends BaseBloc {
  var _repository;
  final _showSticker = BehaviorSubject<bool>.seeded(false);
  final _uiActions = BehaviorSubject<UiAction>();
  final _chatHistory = BehaviorSubject<QuerySnapshot>();
  ChatInfo chatInfo;
  String currentUserId;

  ChatBloc([RepositoryService repoService]) {
    _repository = repoService ?? locator<RepositoryService>();
  }

  Observable<UiAction> get actions => _uiActions.stream;

  Observable<QuerySnapshot> get chatHistory => _chatHistory.stream;

  Observable<bool> get showSticker => _showSticker;

  void setShowSticker(bool show) => _showSticker.sink.add(show);

  bool getShowSticker() => _showSticker.value;

  ChatInfo getChatInfo() => chatInfo;

  void getChatHistory() =>
      _chatHistory.addStream(_repository.getChatHistory(chatInfo));

  Future<void> setChatInfo(ChatInfo chatInfo) async {
    this.chatInfo = chatInfo;
  }

  Future<String> getGroupChatId(String peerId) async {
    // read Local
    var groupChatId;
    var prefs = await SharedPreferences.getInstance();
    var id = prefs.getString('id') ?? '';
    if (id.hashCode <= peerId.hashCode) {
      groupChatId = '$id-$peerId';
    } else {
      groupChatId = '$peerId-$id';
    }
    return groupChatId;
  }

  Future uploadFile(File imageFile) async {
    setLoading(true);
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(imageFile);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      String imageUrl = downloadUrl;
      onSendMessage(imageUrl, 1);
      setLoading(false);
    }, onError: (err) {
      setLoading(false);
      _uiActions.sink.add(new UiAction(
          action: ACTIONS.showToast.index,
          message: StringConstant.chat_image_upload_wrong_type));
    });
  }

  void onSendMessage(String content, int type) {
    // type: 0 = text, 1 = image, 2 = sticker
    if (content.trim() != '') {
      _uiActions.sink
          .add(new UiAction(action: ACTIONS.clearTextEditingController.index));

      _repository.sendChatMsg(chatInfo, content, type);

      _uiActions.sink
          .add(new UiAction(action: ACTIONS.animateListScrollController.index));
    } else {
      _uiActions.sink.add(new UiAction(
          action: ACTIONS.showToast.index,
          message: StringConstant.chat_text_empty));
    }
  }

  void dispose() async {
    super.dispose();
    await _showSticker.drain();
    _showSticker.close();
    await _uiActions.drain();
    _uiActions.close();
    await _chatHistory.drain();
    _chatHistory.close();
  }
}
