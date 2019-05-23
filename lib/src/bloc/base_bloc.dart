

import 'package:rxdart/rxdart.dart';

class BaseBloc {
  final _loading = BehaviorSubject<bool>();

  Observable<bool> get loadingObservable => _loading.stream;

  void setLoading(bool loading) {
    _loading.sink.add(loading);
  }

  void dispose() async {
    await _loading.drain();
    _loading.close();
  }
}