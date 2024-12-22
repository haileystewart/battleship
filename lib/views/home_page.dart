// ignore_for_file: use_build_context_synchronously
// ignore_for_file: prefer_typing_uninitialized_variables
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:battleships/api/game_provider.dart';
import 'package:battleships/views/login_page.dart';
import 'package:battleships/views/new_game.dart';
import 'package:battleships/views/play_game.dart';
import 'package:battleships/api/game_api.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static const route = '/homepage';

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  var gameAPI;

  @override
  void initState() {
    super.initState();
    gameAPI = Provider.of<GameAPI>(context, listen: false);
    gameAPI.fetchGames(context);
  }

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    Provider.of<GameProvider>(context, listen: false).setUserName(prefs.getString('user_name').toString());
    Provider.of<GameProvider>(context, listen: false).setUserAccessToken(prefs.getString('access_token').toString());
  }

  DateTime? currentBackPressTime;

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();

    if (currentBackPressTime == null || now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          width: MediaQuery.sizeOf(context).width * 0.5,
          backgroundColor: Colors.grey[100],
          behavior: SnackBarBehavior.floating,

          content: Container(
            height: 20,
            alignment: Alignment.center,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),

            child: const Text('Press again to exit', 
              style: TextStyle(fontFamily: 'Arial', fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black)
            ),
          ),
        ),
      );
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    var showCompletedGamesList = Provider.of<GameProvider>(context, listen: false).showCompletedGamesList;

    return PopScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Center(child: Text('Battleships')),

          actions: [
            IconButton(
              onPressed: () { gameAPI.fetchGames(context); },
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),

        drawer: const SideDrawer(),

        body: Consumer<GameAPI>(
          builder: (context, gameAPI, _) {
            if (gameAPI.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            final games = gameAPI.games;

            return ListView.builder(
              shrinkWrap: true,
              itemCount: games.length,
              itemBuilder: (context, index) {
                final game = games[index];

                return game.status == 3 || game.status == 0
                    ? showCompletedGamesList
                        ? Dismissible(
                            key: Key(game.id.toString()),

                            onDismissed: (direction) async {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Game forfeited')),
                              );

                              await gameAPI.abortGame(context, game.id);
                              games.removeAt(index);
                            },

                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 16.0),
                              child: const Center(child: Icon(Icons.delete, color: Colors.black)),
                            ),

                            child: InkWell(
                              onTap: () { Navigator.of(context).pushNamed(PlayGame.route, arguments: game.id); },
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),

                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,

                                  children: [
                                    Text(
                                      '#${game.id} ${game.status == 3 ? "${game.player1} vs ${game.player2}" : game.status == 0 ? "Waiting for opponent" : ""}',
                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      game.status == 3 ? game.position == game.turn ? "myTurn" : "opponentTurn" : game.status == 0 ? "matchmaking" : "",
                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )
                        : Container()

                    : showCompletedGamesList
                        ? Container()
                        : InkWell(
                            onTap: () { Navigator.of(context).pushNamed(PlayGame.route, arguments: game.id); },

                            child: Padding(
                              padding: const EdgeInsets.all(10.0),

                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                                children: [
                                  Text(
                                    '#${game.id} ${"${game.player1} vs ${game.player2}"}',
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  Text(
                                    game.position == game.status
                                        ? "gameWon"
                                        : "gameLost",

                                    style: const TextStyle(fontWeight: FontWeight.w500)
                                  )
                                ],
                              ),
                            ),
                          );
              },
            );
          },
        ),
      ),
    );
  }
}

class SideDrawer extends StatelessWidget {
  const SideDrawer({super.key});

  Widget newAIGame(String option, context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(option, style: const TextStyle(fontSize: 16)),

      onTap: () {
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed(NewGame.route, arguments: option.toLowerCase());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var game = Provider.of<GameProvider>(context, listen: false);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,

        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,

              children: [
                const Text('Battleships', style: TextStyle(color: Colors.white, fontSize: 26)),
                Text('Logged in as ${game.userName}', style: const TextStyle(color: Colors.white, fontSize: 18)),
              ],
            ),
          ),

          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('New game'),
            onTap: () { Navigator.of(context).pushNamed(NewGame.route, arguments: null); },
          ),

          ListTile(
            leading: const Icon(Icons.computer),
            title: const Text('New game (AI)'),
            onTap: () {
              Navigator.of(context).pop();

              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    insetPadding: EdgeInsets.symmetric(horizontal: MediaQuery.sizeOf(context).width * 0.05),
                    title: const Text('What AI do you wish to play against?', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),

                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        newAIGame('Random', context),
                        newAIGame('Perfect', context),
                        newAIGame('One ship (A1)', context),
                      ],
                    ),
                  );
                },
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.list),
            title: Text(game.showCompletedGamesList ? 'Show completed games' : 'Show active games'),

            onTap: () {
              Provider.of<GameProvider>(context, listen: false).toggle();
              Navigator.of(context).pushNamedAndRemoveUntil(HomePage.route, (route) => false);
            },
          ),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log out'),

            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.remove('access_token');

              Navigator.of(context).pushNamedAndRemoveUntil(LoginPage.route, (route) => false);
            },
          ),
        ],
      ),
    );
  }
}
