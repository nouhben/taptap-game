import 'dart:ui';
import 'dart:math';

import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/gestures.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xania/components/enemy.dart';
import 'package:xania/components/health_bar.dart';
import 'package:xania/components/highscore_text.dart';
import 'package:xania/components/player.dart';
import 'package:xania/components/score_text.dart';
import 'package:xania/components/start_text.dart';
import 'package:xania/enemy_spawner.dart';
import 'package:xania/state.dart';

class GameController extends Game {
  final SharedPreferences storage;
  Random rand;
  Size screenSize;
  double tileSize;
  Player player;
  EnemySpawner enemySpawner;
  List<Enemy> enemies;
  HealthBar healthBar;
  int score;
  ScoreText scoreText;
  State state;
  HighscoreText highscoreText;
  StartText startText;

  GameController(this.storage) {
    initialize();
  }

  void initialize() async {
    resize(await Flame.util.initialDimensions());
    state = State.menu;
    rand = Random();
    player = Player(this);
    enemies = List<Enemy>();
    enemySpawner = EnemySpawner(this);
    healthBar = HealthBar(this);
    score = 0;
    scoreText = ScoreText(this);
    highscoreText = HighscoreText(this);
    startText = StartText(this);
  }

  void render(Canvas c) {
    Rect background = Rect.fromLTWH(0, 0, screenSize.width, screenSize.height);
    Paint backgroundPaint = Paint()..color = Color(0xFFFAFAFA);
    c.drawRect(background, backgroundPaint);

    player.render(c);

    if (state == State.menu) {
      startText.render(c);
      highscoreText.render(c);
    } else if (state == State.playing) {
      enemies.forEach((Enemy enemy) => enemy.render(c));
      scoreText.render(c);
      healthBar.render(c);
    }
  }

  void update(double t) {
    if (state == State.menu) {
      //do start button update
      startText.update(t);
      //high score text .update to print the pervious highiest score
      highscoreText.update(t);
    } else if (state == State.playing) {
      enemySpawner.update(t);
      //update the health of each enemy
      enemies.forEach((Enemy enemy) => enemy.update(t));
      //remove the dead enemies from the enemy list
      enemies.removeWhere((Enemy enemy) => enemy.isDead);
      player.update(t);
      scoreText.update(t);
      healthBar.update(t);
    }
  }

  void resize(Size size) {
    screenSize = size;
    tileSize = screenSize.width / 10;
  }

  void onTapDown(TapDownDetails d) {
    if (state == State.menu) {
      state = State.playing;
    } else if (state == State.playing) {
      //check for each enemy if we tap on it
      //to decrease its health
      enemies.forEach((Enemy enemy) {
        if (enemy.enemyRect.contains(d.globalPosition)) {
          enemy.onTapDown();
        }
      });
    }
  }

  void spawnEnemy() {
    double x, y;
    switch (rand.nextInt(4)) {
      case 0:
        //Top screen or north
        //x will be anywhere on the top horizon
        x = rand.nextDouble() * screenSize.width;
        //y is up the roof lol
        y = -tileSize * 2.5;
        break;
      case 1:
        //right screen or west
        //x will be anywhere on the right side but outside of course
        x = screenSize.width + tileSize * 2.5;
        //y is up the roof lol
        y = rand.nextDouble() * screenSize.height;
        break;
      case 2:
        //Bottom screen or south
        //x will be anywhere  the bottom edge
        x = rand.nextDouble() * screenSize.width;
        //y is up the roof lol
        y = screenSize.height + tileSize * 2.5;
        break;
      case 3:
        //left screen or east
        //x will be anywhere  the outside left edge
        x = -tileSize * 2.5;
        y = rand.nextDouble() * screenSize.height;
        break;
    }
    enemies.add(Enemy(this, x, y));
  }
}
