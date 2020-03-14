import 'dart:ui';

import 'package:xania/game_controller.dart';

class Enemy {
  final GameController gameController;
  int health;
  int damage;
  double speed;
  Rect enemyRect;
  bool isDead = false;

  Enemy(this.gameController, double x, double y) {
    health = 3;
    damage = 1;
    speed = gameController.tileSize * 2;
    enemyRect = Rect.fromLTWH(
      x,
      y,
      gameController.tileSize * 1.2,
      gameController.tileSize * 1.2,
    );
  }

  void render(Canvas c) {
    Color color;
    switch (health) {
      case 1:
        color = Color(0xFFFF7F7F);
        break;
      case 2:
        color = Color(0xFFFF4C4C);
        break;
      case 3:
        color = Color(0xFFFF4500);
        break;
      default:
        color = Color(0xFFFF0000);
        break;
    }
    Paint enemyColor = Paint()..color = color;
    c.drawRect(enemyRect, enemyColor);
  }

  void update(double t) {
    if (!isDead) {
      double stepDistance = speed * t; //the distance the enemy walks in a frame
      //distance separating the enemy from the player or our player's position
      Offset toPlayer =
          gameController.player.playerRect.center - enemyRect.center;
      //we need to let the enemy moves towards the player's position
      //no matter where he is
      // the -gameController.tileSize * 1.25 is used to leave some space
      //between the player end the enemy
      if (stepDistance <= toPlayer.distance - gameController.tileSize * 1.25) {
        Offset stepToPlayer =
            Offset.fromDirection(toPlayer.direction, stepDistance);
        //moves the enemy towards the specified position
        enemyRect = enemyRect.shift(stepToPlayer);
      } else {
        attack();
      }
    }
  }

  void attack() {
    if (!gameController.player.isDead) {
      gameController.player.currentHealth -= damage;
    }
  }

  void onTapDown() {
    if (!isDead) {
      health--;
      if (health <= 0) {
        isDead = true;
        gameController.score++;
        if (gameController.score >
            (gameController.storage.getInt('highscore') ?? 0)) {
          gameController.storage.setInt('highscore', gameController.score);
        }
      }
    }
  }
}
