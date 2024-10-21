import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(SpinBottleApp());

class SpinBottleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: SpinBottleGame(),
    );
  }
}

class SpinBottleGame extends StatefulWidget {
  @override
  _SpinBottleGameState createState() => _SpinBottleGameState();
}

class _SpinBottleGameState extends State<SpinBottleGame> {
  List<String> players = ['Alice', 'Bob', 'Charlie', 'Dave'];
  String currentPlayer = '';

  void spinBottle() {
    setState(() {
      int randomIndex = Random().nextInt(players.length);
      currentPlayer = players[randomIndex];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Spin the Bottle', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.purple,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Current Player: $currentPlayer',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.purpleAccent),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: TextStyle(fontSize: 18),
              ),
              onPressed: spinBottle,
              child: Text('Spin Bottle'),
            ),
            SizedBox(height: 20),
            Text('Players:', style: TextStyle(fontSize: 20, color: Colors.black)),
            for (String player in players)
              Text(
                player,
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              ),
          ],
        ),
      ),
    );
  }
}