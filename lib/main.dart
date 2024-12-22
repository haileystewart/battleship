import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:battleships/views/home_page.dart';
import 'package:battleships/views/login_page.dart';
import 'package:battleships/views/new_game.dart';
import 'package:battleships/views/play_game.dart';
import 'package:battleships/api/game_provider.dart';
import 'package:battleships/api/game_api.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? accessToken = prefs.getString('access_token');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<GameProvider>(create: (context) => GameProvider()),
        ChangeNotifierProvider<GameAPI>(create: (context) => GameAPI())
      ],

      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Battleships',
        home: (accessToken != null) ? const LoginPage() : const HomePage(),
        routes: {
            LoginPage.route: (context) => const LoginPage(),
            HomePage.route: (context) => const HomePage(),
            NewGame.route: (context) => const NewGame(),
            PlayGame.route: (context) => const PlayGame(),
        }
      ),
    ),
  );
}
