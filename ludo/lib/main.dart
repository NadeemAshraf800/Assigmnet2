import 'dart:math';
import 'package:flutter/material.dart';

class Player {
  final String name;
  int position;
  int score;
  bool hasStarted;
  int rolls; // Counter for the number of rolls

  Player(this.name, {this.position = 0, this.score = 0, this.hasStarted = false, this.rolls = 0});

  void move(int steps) {
    if (hasStarted) {
      position += steps;
      if (position >= 100) {
        print('$name has finished the game!');
        position = 100;
      }
      score = position; // Score is updated as the current position.
    } else {
      if (steps == 6) {
        hasStarted = true;
        print('$name has started the game!');
      } else {
        print('$name needs a 6 to start.');
      }
    }
  }

  bool canRoll() {
    return rolls < 5;
  }

  void incrementRolls() {
    rolls++;
  }
}

class LudoGame {
  final List<Player> players = [];
  int currentPlayerIndex = 0;
  int round = 1;
  int lastDiceRoll = 1; // Store the last dice roll

  LudoGame(List<String> playerNames) {
    for (var name in playerNames) {
      players.add(Player(name));
    }
  }

  void rollDice() {
    Player currentPlayer = players[currentPlayerIndex];

    if (currentPlayer.canRoll()) {
      lastDiceRoll = Random().nextInt(6) + 1;
      print('${currentPlayer.name} rolled a $lastDiceRoll');

      currentPlayer.move(lastDiceRoll);
      currentPlayer.incrementRolls();

      if (lastDiceRoll != 6 || !currentPlayer.canRoll()) {
        nextPlayer();
      }
    } else {
      print('${currentPlayer.name} has already rolled 5 times.');
      nextPlayer();
    }
  }

  void nextPlayer() {
    currentPlayerIndex = (currentPlayerIndex + 1) % players.length;

    if (currentPlayerIndex == 0) {
      round++;
      print('Round $round completed.');
    }

    print('Next turn: ${players[currentPlayerIndex].name}');
  }

  bool isGameOver() {
    return players.every((player) => player.rolls >= 5);
  }

  Player getChampion() {
    return players.reduce((a, b) => a.score > b.score ? a : b);
  }
}

void main() {
  runApp(LudoApp());
}

class LudoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Ludo Game with 4 Players'),
        ),
        body: LudoBoard(),
      ),
    );
  }
}

class LudoBoard extends StatefulWidget {
  @override
  _LudoBoardState createState() => _LudoBoardState();
}

class _LudoBoardState extends State<LudoBoard> with SingleTickerProviderStateMixin {
  LudoGame game = LudoGame(['Player 1', 'Player 2', 'Player 3', 'Player 4']);
  String currentPlayerName = 'Player 1';
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  int diceFace = 1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // Spin the dice for 1 second
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void rollDiceAndUpdate() {
    setState(() {
      _controller.forward(from: 0).whenComplete(() {
        // After the animation is complete, roll the dice and update
        game.rollDice();
        diceFace = game.lastDiceRoll; // Update the dice face based on roll result
        currentPlayerName = game.players[game.currentPlayerIndex].name;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Animated dice image
        AnimatedBuilder(
          animation: _rotationAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationAnimation.value,
              child: Image.asset(
                'assets/dice$diceFace.jpeg', // Display the current dice face
                width: 100,
                height: 100,
              ),
            );
          },
        ),

        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Round ${game.round}',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),

        Expanded(
          child: ListView.builder(
            itemCount: game.players.length,
            itemBuilder: (context, index) {
              Player player = game.players[index];
              return ListTile(
                title: Text(
                  '${player.name} ${player.score == game.getChampion().score ? "(Champion)" : ""}',
                  style: TextStyle(
                    fontWeight: player.score == game.getChampion().score
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: player.score == game.getChampion().score
                        ? Colors.blue
                        : Colors.black,
                  ),
                ),
                subtitle: Text('Position: ${player.position}, Score: ${player.score}, Rolls: ${player.rolls}/5'),
                trailing: player.hasStarted
                    ? Icon(Icons.check_circle, color: Colors.green)
                    : Icon(Icons.cancel, color: Colors.red),
              );
            },
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '$currentPlayerName\'s turn to roll the dice',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),

        ElevatedButton(
          onPressed: () {
            if (!game.isGameOver()) {
              rollDiceAndUpdate();
            } else {
              showGameOverDialog(context);
            }
          },
          child: Text('Roll Dice'),
        ),
      ],
    );
  }

  void showGameOverDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Game Over'),
          content: Text('${game.getChampion().name} is the Champion with the highest score of ${game.getChampion().score}!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
