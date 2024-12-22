// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:battleships/api/game_api.dart';
import 'package:battleships/views/home_page.dart';
import 'package:battleships/api/game_provider.dart';

class NewGame extends StatefulWidget {
  const NewGame({super.key});
  static const route = '/newgame';

  @override
  State<NewGame> createState() => _NewGameState();
}

class GridItem {
  String text;
  bool isSelected;
  bool isHovering;

  GridItem(this.text, this.isSelected) : isHovering = false;
}

class _NewGameState extends State<NewGame> {
  bool isLoading = false;
  int selectedCount = 0;
  int selected = 0;
  String? ai;
  late List<List<GridItem>> grid;

  @override
  void initState() {
    super.initState();

    grid = List.generate(6,
      (row) => List.generate(6,
        (col) => GridItem('', false),
      ),
    );

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
  }

  void selectBox(int row, int col) {
    setState(() {
      bool currentBoxSelected = grid[row][col].isSelected;

      if (currentBoxSelected)
      {
        grid[row][col].isSelected = false;
        selected--;
      }
      else
      {
        if (selected < 5)
        {
          grid[row][col].isSelected = true;
          selected++;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ai = ModalRoute.of(context)!.settings.arguments as String?;

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Place ships')),

        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () { Navigator.pop(context); },
          ),
        ),

      body: isLoading ?
        const Center(child: CircularProgressIndicator()) :

        Column(
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
                      onTap: () => selectBox(row, col),
                      child: Container(
                        color: grid[row][col].isSelected ? Colors.blue[300] : (item.isHovering ? Colors.lightGreen : Colors.white),
                        child: const Center(child: Text("."/* DEBUG grid[row][col].text*/)),
                      ),
                    ),
                  );
                }
              ),
            ),

            Center(
              child: ElevatedButton(
                onPressed: submit,
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
    );
  }

  Future<void> submit() async {
    final gameStartProvider = GameAPI();
    
    List<String> selectedShips = [];

    if (selected < 5) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You must place five ships')));
      return;
    }

    for (int row = 1; row <= 5; row++) {
      for (int col = 1; col <= 5; col++) {
        if (grid[row][col].isSelected) {
          selectedShips.add(grid[row][col].text);
        }
      }
    }

    setState(() { isLoading = true; });

    if (ai.toString().contains('one')) {
      ai = 'oneship';
    }

    await gameStartProvider.startGame(context, selectedShips, ai: ai);

    setState(() { isLoading = false; });

    Provider.of<GameProvider>(context, listen: false).setShowCompletedGamesList(true);
    Navigator.of(context).pushNamedAndRemoveUntil(HomePage.route, (route) => false);
  }
}