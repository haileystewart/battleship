// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:battleships/views/login_page.dart';
import 'package:battleships/models/login.dart';
import 'package:battleships/models/game.dart';
import 'package:battleships/models/game_start.dart';
import 'package:battleships/models/game_information.dart';
import 'package:battleships/models/game_shot.dart';

class GameAPI extends ChangeNotifier {
  static const String gameAPIUrl = 'http://165.227.117.48';

  bool _isLoading = false;
  List<GameResponse> _games = [];
  GameInformationResponse? _gameInfo;

  bool get isLoading => _isLoading;
  List<GameResponse> get games => _games;
  GameInformationResponse? get gameInfo => _gameInfo;

  Future<String?> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  void setLoading(bool state) {
    _isLoading = state;
    Future.delayed(Duration.zero, () { notifyListeners(); });
  }

  void expiredTokenHandler(BuildContext context) async {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Token has expired. Please login again.'),
      ));

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');

      Navigator.of(context).pushNamedAndRemoveUntil(LoginPage.route, (route) => false);
  }

  Future<LoginResponse> login(String username, String password, bool register) async {
    setLoading(true);

    String methodName = register ? "register" : "login";

    final response = await http.post(
      Uri.parse('$gameAPIUrl/$methodName'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    setLoading(false);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return LoginResponse.fromJson(data);
    }

    else {
      throw Exception('$methodName failed');
    }
  }

  Future<void> fetchGames(BuildContext context) async {
    setLoading(true);

    String? accessToken = await getAccessToken();

    final response = await http.get(
      Uri.parse('$gameAPIUrl/games'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
    );

    setLoading(false);

    if (response.statusCode == 200) {
      final List<dynamic> gamesData = jsonDecode(response.body)['games'];
      _games = gamesData.map((game) => GameResponse.fromJson(game)).toList();
    }
    
    else if (response.statusCode == 401)
    {
      expiredTokenHandler(context);
    }
    else 
    {
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  Future<void> getGameInfo(BuildContext context, int gameId) async {
    setLoading(true);

    String? accessToken = await getAccessToken();

    final response = await http.get(
      Uri.parse('$gameAPIUrl/games/$gameId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
    );

    setLoading(false);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      _gameInfo = GameInformationResponse.fromJson(responseData);
    }

    else if (response.statusCode == 401)
    {
      expiredTokenHandler(context);
    }
    else 
    {
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  Future<GameStartResponse?> startGame(BuildContext context, List<String> ships, {String? ai}) async {
    setLoading(true);

    String? accessToken = await getAccessToken();

    final Map<String, dynamic> requestBody = ai == null
        ? { 'ships': ships }
        : { 'ships': ships, 'ai': ai };

    final response = await http.post(
      Uri.parse('$gameAPIUrl/games'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
      body: jsonEncode(requestBody),
    );

    setLoading(false);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return GameStartResponse.fromJson(responseData);
    }
    
    else if (response.statusCode == 401)
    {
      expiredTokenHandler(context);
    }
    else 
    {
      throw Exception(jsonDecode(response.body)['error']);
    }

    return null;
  }

  Future<void> abortGame(BuildContext context, int gameId) async {
    setLoading(true);

    String? accessToken = await getAccessToken();

    final response = await http.delete(
      Uri.parse('$gameAPIUrl/games/$gameId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
    );

    setLoading(false);

    if (response.statusCode == 200) {
      //!!!! NO NEED TO INTERROGATE RESPONSE
      //final Map<String, dynamic> responseData = jsonDecode(response.body);
    }
    
    else if (response.statusCode == 401)
    {
      expiredTokenHandler(context);
    }
    else
    {
      throw Exception(jsonDecode(response.body)['error']);
    }
  }
  
  Future<GameShotResponse?> fireShot(BuildContext context, int gameId, String shot) async {
    setLoading(true);

    String? accessToken = await getAccessToken();

    final response = await http.put(
      Uri.parse('$gameAPIUrl/games/$gameId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
      body: jsonEncode({'shot': shot}),
    );

    setLoading(false);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return GameShotResponse.fromJson(responseData);
    }
    
    else if (response.statusCode == 401)
    {
      expiredTokenHandler(context);
    }
    else 
    {
      throw Exception(jsonDecode(response.body)['error']);
    }

    return null;
  }
}
