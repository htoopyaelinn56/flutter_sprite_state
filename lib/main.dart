import 'package:flame/input.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'cat_player.dart';

void main() {
  runApp(App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final MyGame _game;

  @override
  void initState() {
    super.initState();
    _game = MyGame();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            GameWidget(game: _game),
            ValueListenableBuilder<bool>(
              valueListenable: _game.isDeadNotifier,
              builder: (context, isDead, child) {
                if (isDead) {
                  return Center(
                    child: ElevatedButton(
                      onPressed: () {
                        _game.catPlayer.reset();
                      },
                      child: const Text('Restart'),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MyGame extends FlameGame {
  late final CatPlayer catPlayer;
  final ValueNotifier<bool> isDeadNotifier = ValueNotifier(false);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    catPlayer = CatPlayer()..position = size / 2 - Vector2.all(100);
    add(catPlayer);
  }

  @override
  void update(double dt) {
    super.update(dt);
    isDeadNotifier.value = catPlayer.isDead;
  }
}
