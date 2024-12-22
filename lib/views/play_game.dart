// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:battleships/api/game_api.dart';
import 'package:battleships/views/home_page.dart';

class PlayGame extends StatefulWidget {
  const PlayGame({super.key});
  static const route = '/playgame';

  @override
  State<PlayGame> createState() => PlayGameState();
}

class GridItem {
  String text;
  bool isShips;
  bool isShotLocation;
  bool isSunk;
  bool isWrecks;
  bool isBomb;
  bool isHovering;

  GridItem(this.text, this.isShips, this.isShotLocation, this.isSunk, this.isWrecks, this.isBomb) : isHovering = false;
}

class PlayGameState extends State<PlayGame> {
  bool isLoading = false;
  bool refresh = false;

  List<List<GridItem>> grid = List.generate(6, (row) => List.generate(6, (col) => GridItem('', false, false, false, false, false)));

  int selectedCount = 0;

  @override
  void initState() {
    super.initState();

    // Initialize the grid with A-E and 1-5 headers
    for (int i = 1; i <= 5; i++) {
      grid[0][i].text = i.toString(); // Top headers (1-5)
      grid[i][0].text = String.fromCharCode('A'.codeUnitAt(0) + i - 1); // Side headers (A-E)
    }

    // Initialize the internal text
    for (int r=0; r < 5; r++)
    {
      for (int c=0; c < 5; c++)
      {
        grid[r+1][c+1].text = '${String.fromCharCode('A'.codeUnitAt(0) + r)}${c + 1}';
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      var gameId = ModalRoute.of(context)!.settings.arguments as int;

      Provider.of<GameAPI>(context, listen: false).getGameInfo(context, gameId);
    });
  }

  Future<bool> onWillPop() {
    if (refresh) {
      Navigator.of(context).pushNamedAndRemoveUntil(HomePage.route, (route) => false);
      return Future.value(false);
    }

    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Center(child: Text('Play Game')),

          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),

            onPressed: () {
              if (refresh) {
                Navigator.of(context).pushNamedAndRemoveUntil(HomePage.route, (route) => false);
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ),

        body: isLoading ?
          const Center(child: CircularProgressIndicator()) :

          Consumer<GameAPI>(
            builder: (context, gameProvider, _) {
              if (gameProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              } 
              else {
                // initial state cleared
                for (int row = 1; row <= 5; row++) {
                  for (int col = 1; col <= 5; col++) {
                    grid[row][col].isShips = false;
                    grid[row][col].isSunk = false;
                    grid[row][col].isWrecks = false;
                    grid[row][col].isBomb = false;
                  }
                }

                for (String shipLocation in gameProvider.gameInfo!.ships) {
                  int col = shipLocation.codeUnitAt(0) - 'A'.codeUnitAt(0);
                  int row = int.parse(shipLocation.substring(1)) - 1;
                  grid[row+1][col+1].isShips = true;
                }
                
                for (String sunk in gameProvider.gameInfo!.sunk) {
                  int col = sunk.codeUnitAt(0) - 'A'.codeUnitAt(0);
                  int row = int.parse(sunk.substring(1)) - 1;
                  grid[row+1][col+1].isSunk = true;
                }

                for (String wrecks in gameProvider.gameInfo!.wrecks) {
                  int col = wrecks.codeUnitAt(0) - 'A'.codeUnitAt(0);
                  int row = int.parse(wrecks.substring(1)) - 1;
                  grid[row+1][col+1].isWrecks = true;
                }

                for (String bomb in gameProvider.gameInfo!.shots) {
                  int col = bomb.codeUnitAt(0) - 'A'.codeUnitAt(0);
                  int row = int.parse(bomb.substring(1)) - 1;
                  grid[row+1][col+1].isBomb = true;
                }
              }

              return Column(
                children: [
                  Expanded(child: 
                    GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6,
                        childAspectRatio: 2.5,
                      ),

                      itemCount: 6*6,

                      itemBuilder: (BuildContext context, int index) {
                        final int row = index ~/ 6;
                        final int col = index % 6;
                        final GridItem item = grid[row][col];

                        if (row == 0 || col == 0) {
                          // Header cells are non-interactive
                          return Container(
                            color: Colors.grey[300],
                            child: Center(child: Text(item.text, style: const TextStyle(fontWeight: FontWeight.bold))),
                          );
                        }

                        // Interactive cells
                        return MouseRegion(
                          onEnter: (_) => setState(() => item.isHovering = true),
                          onExit: (_) => setState(() => item.isHovering = false),

                          child: GestureDetector(
                            onTap: () {
                              if (gameProvider.gameInfo?.turn != gameProvider.gameInfo ?.position || 
                                gameProvider.gameInfo?.status == 1 || 
                                gameProvider.gameInfo?.status == 2 || 
                                gameProvider.gameInfo?.status == 0) {
                                return;
                              }

                              for (int r = 1; r <= 5; r++) {
                                for (int c = 1; c <= 5; c++) {
                                  grid[r][c].isShotLocation = (r == row && c == col);
                                }
                              }
                            },

                            child: Container(
                              color: item.isHovering ? Colors.lightGreen : grid[row][col].isShotLocation ? Colors.redAccent : Colors.white,

                              child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,

                                      children: [
                                        //!!!! DEBUG Center(child: Text(grid[row][col].text)),

                                        if (grid[row][col].isShips && !grid[row][col].isWrecks)
                                          Image.asset('images/ship.png', fit: BoxFit.scaleDown),

                                        if (grid[row][col].isSunk)
                                          Image.asset('images/explosion.png', fit: BoxFit.scaleDown)

                                        else if (grid[row][col].isBomb)
                                          Image.asset('images/bomb.png', fit: BoxFit.scaleDown),

                                        if (grid[row][col].isWrecks)
                                          Image.asset('images/wrecks.png', fit: BoxFit.scaleDown),
                                      ],
                                    )
                                ),
                            ),
                        );
                      }
                    )
                  ),

                  Center(
                    child: ElevatedButton(
                      onPressed: 
                          gameProvider.gameInfo?.turn != gameProvider.gameInfo?.position ||
                          gameProvider.gameInfo?.status == 1 ||
                          gameProvider.gameInfo?.status == 2 ||
                          gameProvider.gameInfo?.status == 0 ?
                        null :
                        () => submit(gameProvider.gameInfo!.id),

                      child: const Text('Submit'),
                    ),
                  )
                ]
              );
            },
          ),
      ),
    );
  }

  Future<void> submit(int id) async {
    final gameStartProvider = Provider.of<GameAPI>(context, listen: false);

    String? shotLocation;
    for (int row = 1; row <= 5; row++) {
      for (int col = 1; col <= 5; col++) {
        if (grid[row][col].isShotLocation) {
          shotLocation = String.fromCharCode('A'.codeUnitAt(0) + (col-1)) + row.toString();
        }
      }
    }

    if (shotLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must locate a shot')),
      );
      return;
    }

    setState(() { isLoading = true; });

    try {
      final response = await gameStartProvider.fireShot(context, id, shotLocation.toString());

      // clear shot
      for (int row = 1; row <= 5; row++) {
        for (int col = 1; col <= 5; col++) {
          grid[row][col].isShotLocation = false;
        }
      }

      await gameStartProvider.getGameInfo(context, id);

      if (response != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.sunkShip ? 'Ship sunk!' : 'No enemy ship hit'))
        );
      }

      setState(() { isLoading = false; });

      refresh = true;

      if (response != null && response.won) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Game Over'),
              content: const Text('You won!'),
              actions: <Widget>[
                TextButton(
                  onPressed: () { Navigator.of(context).pop(); },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
    
    catch (e) {
      setState(() { isLoading = false; });

      String errorMessage = e.toString();

      if (errorMessage.startsWith('Exception:')) {
        errorMessage = errorMessage.substring('Exception:'.length).trim();
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }
}
