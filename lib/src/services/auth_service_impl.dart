import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_demo_chat/src/model/user.dart';
import 'package:flutter_demo_chat/src/services/repository_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';
import 'auth_service.dart';

class AuthServiceImpl implements AuthService {
  final _repository = locator<RepositoryService>();
  final _currentUser = BehaviorSubject<User>();

  Observable<User> get currentUser => _currentUser.stream;

  void setCurrentUser(User user) {
    _currentUser.sink.add(user);
  }

  User getCurrentUser() {
    return _currentUser.value;
  }

  Future<bool> isUserSignedIn() async {
    return GoogleSignIn().isSignedIn();
  }

  Future<User> getCurrentLocalUser() async {
    var prefs = await SharedPreferences.getInstance();
    User user;
    var id = prefs.getString('id');
    var name = prefs.getString('name');
    var avatar = prefs.getString('avatar');
    var aboutMe = prefs.getString('aboutMe');
    if (id != null) {
      user = User(id: id, name: name, avatar: avatar, aboutMe: aboutMe);
    }
    return user;
  }

  void saveUserLocally(User user) async {
    final _prefs = await SharedPreferences.getInstance();
    _prefs.setString('id', user.id);
    if (user.name != null) {
      _prefs.setString('name', user.name);
    }
    if (user.avatar != null) {
      _prefs.setString('avatar', user.avatar);
    }
    if (user.aboutMe != null) {
      _prefs.setString('aboutMe', user.aboutMe);
    }
  }

  Future<bool> handleUserSignIn() async {
    FirebaseUser firebaseUser;
    GoogleSignInAccount googleUser = await GoogleSignIn().signIn(); // new instance to avoid platform exception
    if (googleUser != null) {
      GoogleSignInAuthentication googleAuth =
          await googleUser.authentication.catchError((error) => null);

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      firebaseUser = await _repository.signInWithCredential(credential);
    }

    if (firebaseUser != null) {
      // Check is already sign up
      var user = await _repository.getUser(firebaseUser.uid);

      if (user == null) {
        // Update data to server if new user
        user = User(
            id: firebaseUser.uid,
            name: firebaseUser.displayName,
            avatar: firebaseUser.photoUrl);

        await _repository.registerUser(user);
      }
      // Write data to local
      setCurrentUser(user);
      saveUserLocally(user);
      return true;
    } else {
      return false;
    }
  }

  Future<void> handleUserSignOut() async {
    final prefs = await SharedPreferences.getInstance();
    await _repository.signOut();
    var googleSignIn = GoogleSignIn();
    await googleSignIn.disconnect().catchError((_) => null);
    await googleSignIn.signOut().catchError((_) => null);
    await prefs.clear();
  }

  @override
  void dispose() async {
    await _currentUser.drain();
    _currentUser.close();
  }
}
