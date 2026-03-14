import 'dart:js_interop';

@JS('__flutterfireModulesReady')
external JSPromise<JSAny?>? get _flutterfireModulesReady;

Future<void> ensureFirebaseWebModulesLoaded() async {
  final pending = _flutterfireModulesReady;
  if (pending != null) {
    await pending.toDart;
  }
}
