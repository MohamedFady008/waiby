import 'package:flutter/foundation.dart';

class AuthController extends ChangeNotifier {
  bool _loggedIn = false;

  bool get loggedIn => _loggedIn;

  // Mock user
  String userId = "U-91441";
  String name = "Mohamed";
  String? photoUrl; // put image url if you want
  bool online = true;

  void login() {
    _loggedIn = true;
    notifyListeners();
  }

  void logout() {
    _loggedIn = false;
    notifyListeners();
  }

  void toggleOnline() {
    online = !online;
    notifyListeners();
  }
}
