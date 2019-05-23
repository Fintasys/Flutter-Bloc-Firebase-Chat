import 'package:flutter_demo_chat/main.dart';
import 'package:flutter_demo_chat/src/bloc/base_bloc.dart';
import 'package:flutter_demo_chat/src/services/auth_service.dart';
import 'package:rxdart/rxdart.dart';

enum Status { signedOut, signedIn, error }

class SignInBloc extends BaseBloc {
  final _statusSubject = BehaviorSubject<Status>.seeded(Status.signedOut);
  final _authService = locator<AuthService>();

  Observable<Status> get status => _statusSubject.stream;

  void isUserSignedIn() async {
    setLoading(true);

    var isSignedIn = await _authService.isUserSignedIn();
    var user = await _authService.getCurrentLocalUser();

    if (isSignedIn && user != null) {
      _authService.setCurrentUser(user);
      _statusSubject.sink.add(Status.signedIn);
    } else {
      _statusSubject.sink.add(Status.signedOut);
      setLoading(false);
    }
  }

  void handleUserSignIn() async {
    setLoading(true);

    var result = await _authService.handleUserSignIn();
    if (result) {
      // Successful signed in
      _statusSubject.sink.add(Status.signedIn);
    } else {
      // Sign in failed
      _statusSubject.sink.add(Status.error);
      setLoading(false);
    }
  }

  void dispose() async {
    super.dispose();
    await _statusSubject.drain();
    _statusSubject.close();
  }
}
