import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_firebase_chat/src/bloc/chat_bloc.dart';
import 'package:flutter_bloc_firebase_chat/src/model/chat_info.dart';
import 'package:flutter_bloc_firebase_chat/src/model/sticker.dart';
import 'package:flutter_bloc_firebase_chat/src/utils/color_const.dart';
import 'package:flutter_bloc_firebase_chat/src/utils/string_const.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'helper/UiAction.dart';

class Chat extends StatelessWidget {
  final ChatInfo chatInfo;

  Chat({Key key, @required this.chatInfo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider<ChatBloc>(
        builder: (context) => ChatBloc(),
        dispose: (context, bloc) => bloc.dispose(),
        child: new Scaffold(
          appBar: new AppBar(
            title: new Text(
              chatInfo.toUser.name,
              style: TextStyle(
                  color: screenTitleColor, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),
          body: new ChatScreen(chatInfo: chatInfo),
        ));
  }
}

class ChatScreen extends StatefulWidget {
  final ChatInfo chatInfo;

  ChatScreen({Key key, @required this.chatInfo}) : super(key: key);

  @override
  State createState() => new ChatScreenState(chatInfo: chatInfo);
}

class ChatScreenState extends State<ChatScreen> {
  final ChatInfo chatInfo;
  ChatBloc _bloc;

  ChatScreenState({Key key, @required this.chatInfo});

  var listMessage;

  final TextEditingController textEditingController =
      new TextEditingController();
  final ScrollController listScrollController = new ScrollController();
  final FocusNode focusNode = new FocusNode();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bloc == null) {
      _bloc = Provider.of<ChatBloc>(context);
      _blocListener(context, _bloc);
      _bloc.setChatInfo(chatInfo).then((_) => _bloc.getChatHistory());
    }
  }

  @override
  void initState() {
    super.initState();
    focusNode.addListener(onFocusChange);
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker when keyboard appear
      _bloc.setShowSticker(false);
    }
  }

  void _blocListener(BuildContext context, ChatBloc chatBloc) {
    final actionListener = (UiAction action) {
      if (action.action == ACTIONS.clearTextEditingController.index) {
        textEditingController.clear();
      } else if (action.action == ACTIONS.animateListScrollController.index) {
        listScrollController.animateTo(0.0,
            duration: Duration(milliseconds: 300), curve: Curves.easeOut);
      } else if (action.action == ACTIONS.showToast.index) {
        Fluttertoast.showToast(msg: action.message);
      } else if (action.action == ACTIONS.error.index) {}
    };
    chatBloc.actions.listen(actionListener);
  }

  Future getImage() async {
    File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (imageFile != null) {
      _bloc.uploadFile(imageFile);
    }
  }

  void getSticker() {
    // Hide keyboard when sticker appear
    focusNode.unfocus();
    _bloc.setShowSticker(!_bloc.getShowSticker());
  }

  Widget buildItem(int index, DocumentSnapshot document) {
    if (document['idFrom'] == _bloc.chatInfo.fromUser.id) {
      // Right (my message)
      return Row(
        children: <Widget>[
          document['type'] == 0
              // Text
              ? Container(
                  child: Text(
                    document['content'],
                    style: TextStyle(color: textBlackColor),
                  ),
                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  width: 200.0,
                  decoration: BoxDecoration(
                      color: bgGreyColor,
                      borderRadius: BorderRadius.circular(8.0)),
                  margin: EdgeInsets.only(
                      bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                      right: 10.0),
                )
              : document['type'] == 1
                  // Image
                  ? Container(
                      child: Material(
                        child: CachedNetworkImage(
                          placeholder: (context, url) => Container(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      primaryColor),
                                ),
                                width: 200.0,
                                height: 200.0,
                                padding: EdgeInsets.all(70.0),
                                decoration: BoxDecoration(
                                  color: bgGreyColor,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                ),
                              ),
                          errorWidget: (context, url, error) => Material(
                                child: Container(
                                  width: 200,
                                  height: 200,
                                  color: bgGreyColor,
                                  child: Center(
                                      child: Icon(
                                    Icons.error,
                                    color: Colors.red,
                                    size: 64,
                                  )),
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                                clipBehavior: Clip.hardEdge,
                              ),
                          imageUrl: document['content'],
                          width: 200.0,
                          height: 200.0,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        clipBehavior: Clip.hardEdge,
                      ),
                      margin: EdgeInsets.only(
                          bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                          right: 10.0),
                    )
                  // Sticker
                  : Container(
                      child: new Image.asset(
                        'assets/stickers/angry_cat/${document['content']}.png',
                        width: 100.0,
                        height: 100.0,
                        fit: BoxFit.cover,
                      ),
                      margin: EdgeInsets.only(
                          bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                          right: 10.0),
                    ),
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    } else {
      // Left (peer message)
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Material(
                  child: CachedNetworkImage(
                    placeholder: (context, url) => Container(
                          child: CircularProgressIndicator(
                            strokeWidth: 1.0,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(primaryColor),
                          ),
                          width: 35.0,
                          height: 35.0,
                          padding: EdgeInsets.all(10.0),
                        ),
                    imageUrl: chatInfo.toUser.avatar,
                    width: 35.0,
                    height: 35.0,
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(18.0),
                  ),
                  clipBehavior: Clip.hardEdge,
                ),
                document['type'] == 0
                    ? Container(
                        child: Text(
                          document['content'],
                          style: TextStyle(color: Colors.white),
                        ),
                        padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                        width: 200.0,
                        decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(8.0)),
                        margin: EdgeInsets.only(left: 10.0),
                      )
                    : document['type'] == 1
                        ? Container(
                            child: Material(
                              child: CachedNetworkImage(
                                placeholder: (context, url) => Container(
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                primaryColor),
                                      ),
                                      width: 200.0,
                                      height: 200.0,
                                      padding: EdgeInsets.all(70.0),
                                      decoration: BoxDecoration(
                                        color: bgGreyColor,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(8.0),
                                        ),
                                      ),
                                    ),
                                errorWidget: (context, url, error) => Material(
                                      child: Container(
                                        width: 200,
                                        height: 200,
                                        color: bgGreyColor,
                                        child: Center(
                                            child: Icon(
                                          Icons.error,
                                          color: Colors.red,
                                          size: 64,
                                        )),
                                      ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8.0),
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                    ),
                                imageUrl: document['content'],
                                width: 200.0,
                                height: 200.0,
                                fit: BoxFit.cover,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                              clipBehavior: Clip.hardEdge,
                            ),
                            margin: EdgeInsets.only(left: 10.0),
                          )
                        : Container(
                            child: new Image.asset(
                              'assets/stickers/angry_cat/${document['content']}.png',
                              width: 100.0,
                              height: 100.0,
                              fit: BoxFit.cover,
                            ),
                            margin: EdgeInsets.only(
                                bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                                right: 10.0),
                          ),
              ],
            ),

            // Time
            isLastMessageLeft(index)
                ? Container(
                    child: Text(
                      DateFormat('dd MMM kk:mm').format(
                          DateTime.fromMillisecondsSinceEpoch(
                              int.parse(document['timestamp']))),
                      style: TextStyle(
                          color: greyColor,
                          fontSize: 12.0,
                          fontStyle: FontStyle.italic),
                    ),
                    margin: EdgeInsets.only(left: 50.0, top: 5.0, bottom: 5.0),
                  )
                : Container()
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]['idFrom'] == chatInfo?.getGroupChatId()) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]['idFrom'] != chatInfo?.getGroupChatId()) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> onBackPress() {
    if (_bloc.getShowSticker()) {
      _bloc.setShowSticker(false);
    } else {
      Navigator.pop(context);
    }

    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              // List of messages
              buildListMessage(),

              // Sticker
              buildSticker(),

              // Input content
              buildInput(),
            ],
          ),

          // Loading
          buildLoading()
        ],
      ),
      onWillPop: onBackPress,
    );
  }

  Widget buildSticker() {
    // Todo: make dynamic, put into DB
    var angryCatStickerFiles = ['cat_1', 'cat_2', 'cat_3', 'cat_4', 'cat_5', 'cat_6'];
    var sticker = Sticker(
        id: '1', collection: 'angry_cat', files: angryCatStickerFiles, fileType: 'png');

    var stickerWidget = List<Widget>();
    var stickerPerRow = 3;
    var stickerRowsLength = sticker.files.length / stickerPerRow;
    for (var i = 0; i < stickerRowsLength; i++) {
      var children = List<Widget>();
      for (var j = 0; j < sticker.files.length / stickerRowsLength; j++) {
        children.add(FlatButton(
          onPressed: () => _bloc.onSendMessage(sticker.files[j], 2),
          child: new Image.asset(
            '${StringConstant.asset_sticker}/${sticker.collection}/${sticker.files[j]}.${sticker.fileType}',
            width: 50.0,
            height: 50.0,
            fit: BoxFit.cover,
          ),
        ));
      }
      stickerWidget.add(Row(
          children: children,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly));
    }

    return StreamBuilder(
        stream: _bloc.showSticker,
        initialData: false,
        builder: (context, snapshot) {
          if (snapshot.data == false) {
            return new Container();
          } else {
            return Container(
              child: Column(
                children: stickerWidget,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              ),
              decoration: new BoxDecoration(
                  border: new Border(
                      top: new BorderSide(color: bgGreyColor, width: 0.5)),
                  color: Colors.white),
              padding: EdgeInsets.all(5.0),
              height: 180.0,
            );
          }
        });
  }

  Widget buildLoading() {
    return Positioned(
        child: StreamBuilder(
            stream: _bloc.loadingObservable,
            initialData: false,
            builder: (context, snapshot) {
              if (snapshot.data == true) {
                return new Container(
                  child: Center(
                    child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(primaryColor)),
                  ),
                  color: Colors.white.withOpacity(0.8),
                );
              } else {
                return new Container();
              }
            }));
  }

  Widget buildInput() {
    return Container(
      child: Row(
        children: <Widget>[
          // Button send image
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 1.0),
              child: new IconButton(
                icon: new Icon(Icons.image),
                onPressed: getImage,
                color: primaryColor,
              ),
            ),
            color: Colors.white,
          ),
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 1.0),
              child: new IconButton(
                icon: new Icon(Icons.face),
                onPressed: getSticker,
                color: primaryColor,
              ),
            ),
            color: Colors.white,
          ),

          // Edit text
          Flexible(
            child: Container(
              child: TextField(
                style: TextStyle(color: textBlackColor, fontSize: 15.0),
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText: StringConstant.chat_text_input_hint,
                  hintStyle: TextStyle(color: greyColor),
                ),
                focusNode: focusNode,
              ),
            ),
          ),

          // Button send message
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 8.0),
              child: new IconButton(
                icon: new Icon(Icons.send),
                onPressed: () =>
                    _bloc.onSendMessage(textEditingController.text, 0),
                color: primaryColor,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: new BoxDecoration(
          border:
              new Border(top: new BorderSide(color: bgGreyColor, width: 0.5)),
          color: Colors.white),
    );
  }

  Widget buildListMessage() {
    return Flexible(
      child: StreamBuilder(
        stream: _bloc.chatHistory,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor)));
          } else {
            listMessage = snapshot.data.documents;
            return ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemBuilder: (context, index) =>
                  buildItem(index, snapshot.data.documents[index]),
              itemCount: snapshot.data.documents.length,
              reverse: true,
              controller: listScrollController,
            );
          }
        },
      ),
    );
  }
}
