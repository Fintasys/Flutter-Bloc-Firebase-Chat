import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_demo_chat/src/bloc/sign_in_bloc.dart';
import 'package:flutter_demo_chat/src/services/auth_service.dart';
import 'package:flutter_demo_chat/src/utils/color_const.dart';
import 'package:flutter_demo_chat/src/utils/string_const.dart';
import 'package:flutter_demo_chat/src/widgets/screen_chat_list.dart';
import 'package:provider/provider.dart';

import '../../main.dart';

class SignIn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider<SignInBloc>(
        builder: (context) => SignInBloc(),
        dispose: (context, bloc) => bloc.dispose(),
        child: Scaffold(
            appBar: AppBar(
              title: Text(
                StringConstant.title_login,
                style: TextStyle(
                    color: screenTitleColor, fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
            ),
            body: SignInScreen()));
  }
}

class SignInScreen extends StatefulWidget {
  @override
  SignInScreenState createState() {
    return SignInScreenState();
  }
}

class SignInScreenState extends State<SignInScreen> {
  SignInBloc _bloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bloc == null) {
      _bloc = Provider.of<SignInBloc>(context);
      SchedulerBinding.instance
          .addPostFrameCallback((_) => _bloc.isUserSignedIn());
      _listenStatus(context, _bloc);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment(0.0, 0.0),
        child: Stack(children: <Widget>[
          Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(top: 50.0),
                    child: FlutterLogo(size: 150),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.only(top: 20.0),
                      child: Text(
                        StringConstant.login_logo_desc,
                        style: TextStyle(fontSize: 18.0),
                      )),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(top: 50.0),
                    child: FlatButton(
                        onPressed: _bloc.handleUserSignIn,
                        child: Text(
                          StringConstant.btn_login_google,
                          style: TextStyle(fontSize: 16.0),
                        ),
                        color: Color(0xffdd4b39),
                        highlightColor: Color(0xffff7f7f),
                        splashColor: Colors.transparent,
                        textColor: Colors.white,
                        padding: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0)),
                  ),
                ],
              )
            ],
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
                                AlwaysStoppedAnimation<Color>(primaryColor),
                          ),
                        ),
                        color: Colors.white.withOpacity(0.8),
                      );
                    } else {
                      return new Container();
                    }
                  }))
        ]));
  }

  void _listenStatus(BuildContext context, SignInBloc loginBloc) {
    final onData = (Status status) {
      if (status == Status.error) {
        showErrorMessage();
      } else if (status == Status.signedIn) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatList(
                    currentUserId:
                        locator<AuthService>().getCurrentUser().id)));
      }
    };

    loginBloc.status.listen(onData);
  }

  void showErrorMessage() {
    final snackBar = SnackBar(
        content: Text(StringConstant.error_login_sns),
        duration: new Duration(seconds: 2));
    Scaffold.of(context).showSnackBar(snackBar);
  }
}
