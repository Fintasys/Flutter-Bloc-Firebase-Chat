import 'dart:io';

import 'package:flutter_demo_chat/src/bloc/base_bloc.dart';
import 'package:flutter_demo_chat/src/model/user.dart';
import 'package:flutter_demo_chat/src/services/auth_service.dart';
import 'package:flutter_demo_chat/src/services/repository_service.dart';
import 'package:flutter_demo_chat/src/utils/string_const.dart';
import 'package:flutter_demo_chat/src/widgets/helper/UiAction.dart';
import 'package:rxdart/rxdart.dart';

import '../../main.dart';

enum ACTIONS {
  showToast,
  error,
}

class UserSettingsBloc extends BaseBloc {
  var _repository;
  final _uiActions = BehaviorSubject<UiAction>();
  final _authService = locator<AuthService>();
  User localUser;

  UserSettingsBloc([RepositoryService repoService]) {
    _repository = repoService ?? locator<RepositoryService>();
  }

  Observable<UiAction> get actions => _uiActions.stream;

  void initUser() {
    localUser = _authService.getCurrentUser();
  }

  void setUserAvatar(File image) async {
    setLoading(true);
    await uploadFile(image);
    setLoading(false);
  }

  Future uploadFile(File image) async {
    var doc = await _repository.uploadUserAvatar(
        _authService.getCurrentUser().id, image);

    if (doc.error == null) {
      await doc.ref.getDownloadURL().then((downloadUrl) async {
        localUser.avatar = downloadUrl;
        await _repository.updateUser(localUser).then((user) async {
          _authService.setCurrentUser(user);
          _uiActions.sink.add(new UiAction(
              action: ACTIONS.showToast.index, message: 'Upload success'));
        }).catchError((err) {
          _uiActions.sink.add(new UiAction(
              action: ACTIONS.showToast.index, message: err.toString()));
        });
      }, onError: (err) {
        _uiActions.sink.add(new UiAction(
            action: ACTIONS.showToast.index,
            message: StringConstant.error_upload_type_image));
      });
    } else {
      _uiActions.sink.add(new UiAction(
          action: ACTIONS.showToast.index,
          message: StringConstant.error_upload_type_image));
    }
  }

  void updateUserInfo() async {
    setLoading(true);
    _repository.updateUser(localUser).then((user) {
      _authService.setCurrentUser(user);
      setLoading(false);
      _uiActions.sink.add(new UiAction(
          action: ACTIONS.showToast.index, message: 'Update success'));
    }).catchError((err) {
      setLoading(false);
      _uiActions.sink.add(new UiAction(
          action: ACTIONS.showToast.index, message: err.toString()));
    });
  }

  void dispose() async {
    super.dispose();
    await _uiActions.drain();
    _uiActions.close();
  }
}
