import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_firebase_chat/src/bloc/user_settings_bloc.dart';
import 'package:flutter_bloc_firebase_chat/src/model/user.dart';
import 'package:flutter_bloc_firebase_chat/src/services/auth_service.dart';
import 'package:flutter_bloc_firebase_chat/src/utils/color_const.dart';
import 'package:flutter_bloc_firebase_chat/src/utils/string_const.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import 'helper/UiAction.dart';

class UserSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider<UserSettingsBloc>(
        builder: (context) => UserSettingsBloc(),
        dispose: (context, bloc) => bloc.dispose(),
        child: Scaffold(
          appBar: new AppBar(
            title: new Text(
              StringConstant.title_user_settings,
              style:
                  TextStyle(color: screenTitleColor, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),
          body: new SettingsScreen(),
        ));
  }
}

class SettingsScreen extends StatefulWidget {
  @override
  State createState() => new SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  UserSettingsBloc _bloc;
  TextEditingController controllerNickname;
  TextEditingController controllerAboutMe;

  final FocusNode focusNodeNickname = new FocusNode();
  final FocusNode focusNodeAboutMe = new FocusNode();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bloc == null) {
      _bloc = Provider.of<UserSettingsBloc>(context);
      _blocListener(context, _bloc);
      _bloc.initUser();
      initController();
    }
  }

  void _blocListener(BuildContext context, UserSettingsBloc userSettingsBloc) {
    final actionListener = (UiAction action) {
      if (action.action == ACTIONS.showToast.index) {
        Fluttertoast.showToast(msg: action.message);
      } else if (action.action == ACTIONS.error.index) {}
    };
    userSettingsBloc.actions.listen(actionListener);
  }

  void initController() {
    controllerNickname = new TextEditingController(
        text: locator<AuthService>().getCurrentUser().name);
    controllerAboutMe = new TextEditingController(
        text: locator<AuthService>().getCurrentUser().aboutMe);
  }

  Future getImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      _bloc.setUserAvatar(image);
    }
  }

  void updateUserInfo() async {
    focusNodeNickname.unfocus();
    focusNodeAboutMe.unfocus();
    _bloc.updateUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          child: Column(
            children: <Widget>[
              // Avatar
              Container(
                child: Center(
                  child: Stack(
                    children: <Widget>[
                      StreamBuilder(
                          stream: locator<AuthService>().currentUser,
                          builder: (context, snapshot) {
                            var user = snapshot.data as User;
                            if (snapshot.hasData &&
                                user != null &&
                                user.avatar != null) {
                              return Material(
                                child: CachedNetworkImage(
                                  placeholder: (context, url) => Container(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.0,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  primaryColor),
                                        ),
                                        width: 90.0,
                                        height: 90.0,
                                        padding: EdgeInsets.all(20.0),
                                      ),
                                  imageUrl: user.avatar,
                                  width: 90.0,
                                  height: 90.0,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(45.0)),
                                clipBehavior: Clip.hardEdge,
                              );
                            } else {
                              return Icon(
                                Icons.account_circle,
                                size: 90.0,
                                color: greyColor,
                              );
                            }
                          }),
                      IconButton(
                        icon: Icon(
                          Icons.camera_alt,
                          color: primaryColor.withOpacity(0.5),
                        ),
                        onPressed: getImage,
                        padding: EdgeInsets.all(30.0),
                        splashColor: Colors.transparent,
                        highlightColor: greyColor,
                        iconSize: 30.0,
                      ),
                    ],
                  ),
                ),
                width: double.infinity,
                margin: EdgeInsets.all(20.0),
              ),

              // Input
              Column(
                children: <Widget>[
                  // Username
                  Container(
                    child: Text(
                      'Name',
                      style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          color: primaryColor),
                    ),
                    margin: EdgeInsets.only(left: 10.0, bottom: 5.0, top: 10.0),
                  ),
                  Container(
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(primaryColor: primaryColor),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Firstname Lastname',
                          contentPadding: new EdgeInsets.all(5.0),
                          hintStyle: TextStyle(color: greyColor),
                        ),
                        controller: controllerNickname,
                        onChanged: (value) {
                          _bloc.localUser.name = value;
                        },
                        focusNode: focusNodeNickname,
                      ),
                    ),
                    margin: EdgeInsets.only(left: 30.0, right: 30.0),
                  ),

                  // About me
                  Container(
                    child: Text(
                      'About me',
                      style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          color: primaryColor),
                    ),
                    margin: EdgeInsets.only(left: 10.0, top: 30.0, bottom: 5.0),
                  ),
                  Container(
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(primaryColor: primaryColor),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Fun, like travel and play PES...',
                          contentPadding: EdgeInsets.all(5.0),
                          hintStyle: TextStyle(color: greyColor),
                        ),
                        controller: controllerAboutMe,
                        onChanged: (value) {
                          _bloc.localUser.aboutMe = value;
                        },
                        focusNode: focusNodeAboutMe,
                      ),
                    ),
                    margin: EdgeInsets.only(left: 30.0, right: 30.0),
                  ),
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),

              // Button
              Container(
                child: FlatButton(
                  onPressed: updateUserInfo,
                  child: Text(
                    'UPDATE',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  color: primaryColor,
                  highlightColor: new Color(0xff8d93a0),
                  splashColor: Colors.transparent,
                  textColor: Colors.white,
                  padding: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 10.0),
                ),
                margin: EdgeInsets.only(top: 50.0, bottom: 50.0),
              ),
            ],
          ),
          padding: EdgeInsets.only(left: 15.0, right: 15.0),
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
                          valueColor:
                              AlwaysStoppedAnimation<Color>(primaryColor)),
                    ),
                    color: Colors.white.withOpacity(0.8),
                  );
                } else {
                  return new Container();
                }
              }),
        )
      ],
    );
  }
}
