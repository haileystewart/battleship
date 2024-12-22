import 'package:flutter/material.dart';

class GameProvider extends ChangeNotifier {
  String? _userName;
  String? _userAccessToken;
  bool    _showCompletedGamesList = true;

  String? get userName => _userName;
  String? get userAccessToken => _userAccessToken;
  bool    get showCompletedGamesList => _showCompletedGamesList;

  void setUserAccessToken(String? userAccessToken) {
    _userAccessToken = userAccessToken;
    notifyListeners();
  }

  void setUserName(String userName) {
    _userName = userName;
    notifyListeners();
  }

  void setShowCompletedGamesList(bool showCompletedGamesList) {
    _showCompletedGamesList = showCompletedGamesList;
    notifyListeners();
  }

  void toggle() {
    _showCompletedGamesList = !_showCompletedGamesList;
    notifyListeners();
  }
}
