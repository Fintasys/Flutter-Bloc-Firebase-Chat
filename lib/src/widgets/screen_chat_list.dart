import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_firebase_chat/src/bloc/chat_list_bloc.dart';
import 'package:flutter_bloc_firebase_chat/src/model/chat_info.dart';
import 'package:flutter_bloc_firebase_chat/src/model/user.dart';
import 'package:flutter_bloc_firebase_chat/src/services/auth_service.dart';
import 'package:flutter_bloc_firebase_chat/src/utils/color_const.dart';
import 'package:flutter_bloc_firebase_chat/src/utils/string_const.dart';
import 'package:flutter_bloc_firebase_chat/src/utils/util_nav.dart';
import 'package:flutter_bloc_firebase_chat/src/widgets/screen_chat.dart';
import 'package:flutter_bloc_firebase_chat/src/widgets/helper/NavBarMenuItem.dart';
import 'package:provider/provider.dart';

import '../../main.dart';

class ChatList extends StatelessWidget {
  final String currentUserId;

  ChatList({Key key, @required this.currentUserId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider<ChatListBloc>(
        builder: (context) => ChatListBloc(),
        dispose: (context, bloc) => bloc.dispose(),
        child: ChatListScreen(currentUserId: currentUserId));
  }
}

class ChatListScreen extends StatefulWidget {
  final String currentUserId;

  ChatListScreen({Key key, @required this.currentUserId}) : super(key: key);

  @override
  State createState() => ChatListScreenState(currentUserId: currentUserId);
}

class ChatListScreenState extends State<ChatListScreen> {
  ChatListBloc _bloc;
  final String currentUserId;
  static const int navBarSettings = 1;
  static const int navBarSignOut = 2;

  List<NavBarMenuItem> navBarMenuItems = const <NavBarMenuItem>[
    const NavBarMenuItem(
        key: navBarSettings,
        title: StringConstant.menu_user_settings,
        icon: Icons.settings),
    const NavBarMenuItem(
        key: navBarSignOut,
        title: StringConstant.menu_sign_out,
        icon: Icons.exit_to_app),
  ];

  /// Constructor
  ChatListScreenState({Key key, @required this.currentUserId});

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bloc == null) {
      _bloc = Provider.of<ChatListBloc>(context);
      _blocListener(context, _bloc);
    }
  }

  void _blocListener(BuildContext context, ChatListBloc chatListBloc) {
    final signOutListener = (bool signedOut) {
      if (signedOut) {
        navigateToAndRemoveUntil(context, StringConstant.route_sign_in, null);
      }
    };
    chatListBloc.signedOut.listen(signOutListener);
  }

  Future<Null> openDialog() async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding:
                EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
            children: <Widget>[
              Container(
                color: primaryColor,
                margin: EdgeInsets.all(0.0),
                padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
                height: 100.0,
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.exit_to_app,
                        size: 30.0,
                        color: Colors.white,
                      ),
                      margin: EdgeInsets.only(bottom: 10.0),
                    ),
                    Text(
                      StringConstant.dialog_title_exit_app,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      StringConstant.dialog_title_exit_app_desc,
                      style: TextStyle(color: Colors.white70, fontSize: 14.0),
                    ),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 0);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.cancel,
                        color: primaryColor,
                      ),
                      margin: EdgeInsets.only(right: 10.0),
                    ),
                    Text(
                      StringConstant.cancel.toUpperCase(),
                      style: TextStyle(
                          color: primaryColor, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 1);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.check_circle,
                        color: primaryColor,
                      ),
                      margin: EdgeInsets.only(right: 10.0),
                    ),
                    Text(
                      StringConstant.yes.toUpperCase(),
                      style: TextStyle(
                          color: primaryColor, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ],
          );
        })) {
      case 0:
        break;
      case 1:
        exit(0);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            StringConstant.title_chat_list,
            style: TextStyle(color: screenTitleColor, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: <Widget>[
            PopupMenuButton<NavBarMenuItem>(
              onSelected: onItemMenuPress,
              itemBuilder: (BuildContext context) {
                return navBarMenuItems.map((NavBarMenuItem choice) {
                  return PopupMenuItem<NavBarMenuItem>(
                      value: choice,
                      child: Row(
                        children: <Widget>[
                          Icon(
                            choice.icon,
                            color: primaryColor,
                          ),
                          Container(
                            width: 10.0,
                          ),
                          Text(
                            choice.title,
                            style: TextStyle(color: primaryColor),
                          ),
                        ],
                      ));
                }).toList();
              },
            ),
          ],
        ),
        body: WillPopScope(
          child: Stack(
            children: <Widget>[
              // List
              Container(
                child: StreamBuilder(
                  stream: _bloc.chatList(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                        ),
                      );
                    } else {
                      return ListView.builder(
                        padding: EdgeInsets.all(10.0),
                        itemBuilder: (context, index) =>
                            buildListItem(context, snapshot.data[index]),
                        itemCount: snapshot.data.length,
                      );
                    }
                  },
                ),
              ),

              // Loading
              Positioned(
                  child: StreamBuilder(
                      stream: _bloc.loadingObservable,
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data) {
                          return new Container(
                            child: Center(
                              child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      primaryColor)),
                            ),
                            color: Colors.white.withOpacity(0.8),
                          );
                        } else {
                          return new Container();
                        }
                      }))
            ],
          ),
          onWillPop: onBackPress,
        ));
  }

  Widget buildListItem(BuildContext context, User user) {
    if (user.id == currentUserId) {
      return Container();
    } else {
      return Container(
        child: FlatButton(
          child: Row(
            children: <Widget>[
              Material(
                child: CachedNetworkImage(
                  placeholder: (context, url) => Container(
                        child: CircularProgressIndicator(
                          strokeWidth: 1.0,
                          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                        ),
                        width: 50.0,
                        height: 50.0,
                        padding: EdgeInsets.all(15.0),
                      ),
                  imageUrl: user.avatar,
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.all(Radius.circular(25.0)),
                clipBehavior: Clip.hardEdge,
              ),
              Flexible(
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Text(
                          user.name,
                          style: TextStyle(color: textBlackColor, fontSize: 18.0),
                        ),
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 5.0),
                      ),
                      Container(
                        child: Text(
                          '${StringConstant.list_item_about_me_label}: ${user.aboutMe ?? StringConstant.list_item_about_me_not_available}',
                          style: TextStyle(color: textDarkGrayColor),
                        ),
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                      ),
                    ],
                  ),
                  margin: EdgeInsets.only(left: 20.0),
                ),
              ),
            ],
          ),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Chat(
                        chatInfo: ChatInfo(
                            locator<AuthService>().getCurrentUser(), user))));
          },
          color: bgGreyColor,
          padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
        margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
      );
    }
  }

  Future<bool> onBackPress() async {
    openDialog();
    return Future.value(false);
  }

  void onItemMenuPress(NavBarMenuItem item) {
    if (item.key == navBarSignOut) {
      _bloc.handleSignOut();
    } else if (item.key == navBarSettings) {
      navigateTo(context, StringConstant.route_user_settings, null);
    }
  }
}
