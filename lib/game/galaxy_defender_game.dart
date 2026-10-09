import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:galaxy_defender/data/game_save.dart';
import 'package:galaxy_defender/game/game_config.dart';

class GameStats {
  final int score;
  final int bestScore;
  final int lives;
  final double health;
  final double shield;
  final int wave;
  final bool bossActive;

  const GameStats({
    this.score = 0,
    this.bestScore = 0,
    this.lives = 3,
    this.health = 100,
    this.shield = 50,
    this.wave = 1,
    this.bossActive = false,
  });

  GameStats copyWith({
    int? score,
    int? bestScore,
    int? lives,
    double? health,
    double? shield,
    int? wave,
    bool? bossActive,
  }) {
    return GameStats(
      score: score ?? this.score,
      bestScore: bestScore ?? this.bestScore,
      lives: lives ?? this.lives,
      health: health ?? this.health,
      shield: shield ?? this.shield,
      wave: wave ?? this.wave,
      bossActive: bossActive ?? this.bossActive,
    );
  }
}

class GalaxyDefenderGame extends FlameGame {
  GalaxyDefenderGame({required this.save, this.onGameOver, this.onGameWon})
      : stats = ValueNotifier<GameStats>(const GameStats(bestScore: 0)); {
    camera.viewfinder.visibleGameSize = Vector2(GameConfig.worldWidth, GameConfig.worldHeight);
  }

  final GameSave save;
  final VoidCallback? onGameOver;
  final VoidCallback? onGameWon;
  final ValueNotifier<GameStats> stats;

  final Random _random = Random();
  final List<EnemyShip> _enemies = [];
  final List<Projectile> _playerProjectiles = [];
  final List<Projectile> _enemyProjectiles = [];
  final List<PowerUp> _powerUps = [];
  final List<Explosion> _explosions = [];
  late PlayerShip _player;
  late Starfield _starfield;

  double _enemySpawnTimer = 0;
  double _powerSpawnTimer = 3;
  double _bossTimer = 0;
  double _specialCharge = 100;
  bool _bossActive = false;
  bool _gameOver = false;
  int _score = 0;
  int _lives = GameConfig.startingLives;
  double _health = 100;
  double _shield = 50;
  int _wave = 1;
  int _bestScore = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _starfield = Starfield();
    add(_starfield);

    _player = PlayerShip(
      position: Vector2(GameConfig.worldWidth / 2, GameConfig.worldHeight - 96),
      size: Vector2(42, 58),
    );
    add(_player);

    _bestScore = save.bestScore;
    stats.value = const GameStats(bestScore: 0, lives: GameConfig.startingLives);
    _updateHud();
  }

  void movePlayerBy(double dx, double dy) {
    if (_gameOver) return;
    final movement = Vector2(dx * (0.9 + save.controlsSensitivity * 0.25), dy * (0.9 + save.controlsSensitivity * 0.25));
    _player.position += movement;
    _player.position.x = _player.position.x.clamp(24, GameConfig.worldWidth - 24);
    _player.position.y = _player.position.y.clamp(70, GameConfig.worldHeight - 40);
  }

  void triggerSpecial() {
    if (_gameOver || _specialCharge < 50) return;
    _specialCharge = 0;
    _spawnExplosion(_player.position, 48, const Color(0xFF8BE9FD));
    for (var enemy in _enemies) {
      enemy.takeDamage(45);
      _score += 25;
    }
    _updateHud();
  }

  void updateHud() => _updateHud();

  @override
  void update(double dt) {
    super.update(dt);
    if (_gameOver) return;

    _enemySpawnTimer -= dt;
    _powerSpawnTimer -= dt;
    _bossTimer += dt;
    _specialCharge = (_specialCharge + dt * 7).clamp(0, 100);

    if (_enemySpawnTimer <= 0) {
      _spawnEnemy();
      _enemySpawnTimer = math.max(0.42, GameConfig.enemySpawnInterval - (_wave * 0.05));
    }

    if (_powerSpawnTimer <= 0 && _random.nextDouble() < 0.9) {
      _spawnPowerUp();
      _powerSpawnTimer = 7 + _random.nextDouble() * 5;
    }

    if (_bossTimer > 22 && !_bossActive && _score > GameConfig.bossScoreThreshold) {
      _spawnBoss();
      _bossTimer = 0;
    }

    for (final projectile in List<Projectile>.from(_playerProjectiles)) {
      projectile.position += projectile.velocity * dt;
      if (projectile.position.y < -20 || projectile.position.x < -20 || projectile.position.x > GameConfig.worldWidth + 20) {
        projectile.removeFromParent();
        _playerProjectiles.remove(projectile);
      }
    }

    for (final projectile in List<Projectile>.from(_enemyProjectiles)) {
      projectile.position += projectile.velocity * dt;
      if (projectile.position.y > GameConfig.worldHeight + 40) {
        projectile.removeFromParent();
        _enemyProjectiles.remove(projectile);
      }
    }

    for (final enemy in List<EnemyShip>.from(_enemies)) {
      enemy.position += enemy.velocity * dt;
      if (enemy.position.y > GameConfig.worldHeight + 70) {
        enemy.removeFromParent();
        _enemies.remove(enemy);
      }
      if (enemy.hasReachedPlayer) {
        _hitPlayerDamage(8);
        enemy.removeFromParent();
        _enemies.remove(enemy);
        _spawnExplosion(enemy.position, 36, const Color(0xFFFFB86C));
      }
      if (enemy.health <= 0) {
        enemy.removeFromParent();
        _enemies.remove(enemy);
        _score += enemy.scoreValue;
        _spawnExplosion(enemy.position, enemy.size.x * 0.6, const Color(0xFFFF5E72));
        if (_random.nextDouble() < 0.22) {
          _spawnPowerUpAt(enemy.position, _random.nextBool() ? 'shield' : 'health');
        }
      }
    }

    for (final powerUp in List<PowerUp>.from(_powerUps)) {
      powerUp.position += Vector2(0, 110) * dt;
      if (powerUp.position.y > GameConfig.worldHeight + 40) {
        powerUp.removeFromParent();
        _powerUps.remove(powerUp);
      }
      if (_player.position.distanceTo(powerUp.position) < 34) {
        _applyPowerUp(powerUp.kind);
        powerUp.removeFromParent();
        _powerUps.remove(powerUp);
      }
    }

    for (final explosion in List<Explosion>.from(_explosions)) {
      explosion.updateLife(dt);
      if (explosion.life <= 0) {
        explosion.removeFromParent();
        _explosions.remove(explosion);
      }
    }

    for (final enemy in List<EnemyShip>.from(_enemies)) {
      for (final projectile in List<Projectile>.from(_playerProjectiles)) {
        if (enemy.position.distanceTo(projectile.position) < 22) {
          enemy.takeDamage(projectile.damage);
          projectile.removeFromParent();
          _playerProjectiles.remove(projectile);
          _spawnExplosion(projectile.position, 8, const Color(0xFF8BF5FF));
        }
      }
    }

    for (final projectile in List<Projectile>.from(_enemyProjectiles)) {
      if (_player.position.distanceTo(projectile.position) < 25) {
        _hitPlayerDamage(projectile.damage.toDouble());
        projectile.removeFromParent();
        _enemyProjectiles.remove(projectile);
      }
    }

    if (_health <= 0) {
      _loseLife();
      if (_lives <= 0) {
        _gameOver = true;
        _bestScore = math.max(_bestScore, _score);
        onGameOver?.call();
      }
    }

    if (_score > 1000 && _wave < 3) {
      _wave = 3;
    }

    if (_score > 3000 && _wave < 5) {
      _wave = 5;
    }

    _updateHud();
  }

  void _updateHud() {
    final clampedScore = math.max(_score, 0);
    stats.value = GameStats(
      score: clampedScore,
      bestScore: math.max(_bestScore, clampedScore),
      lives: _lives,
      health: _health.clamp(0, 100),
      shield: _shield.clamp(0, 100),
      wave: _wave,
      bossActive: _bossActive,
    );
  }

  void _spawnEnemy() {
    final x = _random.nextDouble() * (GameConfig.worldWidth - 48) + 24;
    final variant = _random.nextInt(5);
    final enemy = EnemyShip(
      position: Vector2(x, -20),
      size: Vector2(28 + variant * 4, 30 + variant * 3),
      speed: 90 + _wave * 12 + variant * 18,
      health: 30 + _wave * 10 + variant * 16,
      scoreValue: 95 + variant * 30,
      variant: variant,
      movePattern: variant == 0 ? 'zigzag' : variant == 1 ? 'drop' : 'strafe',
    );
    add(enemy);
    _enemies.add(enemy);
  }

  void _spawnBoss() {
    _bossActive = true;
    final boss = EnemyShip(
      position: Vector2(GameConfig.worldWidth / 2, -70),
      size: Vector2(110, 90),
      speed: 55,
      health: 280,
      scoreValue: 800,
      variant: 5,
      movePattern: 'boss',
      isBoss: true,
    );
    add(boss);
    _enemies.add(boss);
  }

  void _spawnPowerUp() {
    final kind = ['shield', 'health', 'rapid', 'score'][_random.nextInt(4)];
    _spawnPowerUpAt(Vector2(_random.nextDouble() * (GameConfig.worldWidth - 30) + 15, -20), kind);
  }

  void _spawnPowerUpAt(Vector2 position, String kind) {
    final powerUp = PowerUp(position: position, kind: kind, size: Vector2(24, 24));
    add(powerUp);
    _powerUps.add(powerUp);
  }

  void _spawnExplosion(Vector2 position, double radius, Color color) {
    final explosion = Explosion(position: position, radius: radius, color: color);
    add(explosion);
    _explosions.add(explosion);
  }

  void _applyPowerUp(String kind) {
    switch (kind) {
      case 'health':
        _health = (_health + 30).clamp(0, 100);
        break;
      case 'shield':
        _shield = (_shield + 35).clamp(0, 100);
        break;
      case 'rapid':
        _player.applyRapidFire();
        break;
      case 'score':
        _score += 300;
        break;
    }
  }

  void _hitPlayerDamage(double amount) {
    if (_shield > 0) {
      final absorb = amount * 0.8;
      _shield -= absorb;
      if (_shield < 0) {
        _health += _shield;
        _shield = 0;
      }
    } else {
      _health -= amount;
    }
    _spawnExplosion(_player.position, 26, const Color(0xFFFF7F50));
  }

  void _loseLife() {
    _lives -= 1;
    _health = 100;
    _shield = 50;
    _player.position = Vector2(GameConfig.worldWidth / 2, GameConfig.worldHeight - 100);
    _spawnExplosion(_player.position, 34, const Color(0xFFBA68C8));
  }

  void shootPlayerProjectile() {
    if (_gameOver) return;
    final bullet = Projectile(
      position: Vector2(_player.position.x, _player.position.y - 24),
      velocity: Vector2(0, -700),
      damage: 18,
      color: const Color(0xFF93F9FF),
      radius: 5,
    );
    add(bullet);
    _playerProjectiles.add(bullet);
  }

  void spawnEnemyShot(EnemyShip enemy) {
    final bullet = Projectile(
      position: Vector2(enemy.position.x, enemy.position.y + 24),
      velocity: Vector2(0, 260),
      damage: 10,
      color: const Color(0xFFFF8A80),
      radius: 6,
    );
    add(bullet);
    _enemyProjectiles.add(bullet);
  }
}

class PlayerShip extends PositionComponent {
  PlayerShip({required super.position, required super.size});

  double _fireTimer = 0;
  bool _rapidFire = false;

  @override
  void update(double dt) {
    super.update(dt);
    if (!parentIsA<GalaxyDefenderGame>()) return;
    final game = parent as GalaxyDefenderGame;
    _fireTimer -= dt;
    if (_fireTimer <= 0) {
      game.shootPlayerProjectile();
      _fireTimer = _rapidFire ? 0.12 : 0.3;
    }
    if (_rapidFire) {
      final rapidTimer = 4.5;
      if (rapidTimer <= 0) {
        _rapidFire = false;
      }
    }
  }

  void applyRapidFire() {
    _rapidFire = true;
  }
}

class EnemyShip extends PositionComponent {
  EnemyShip({
    required super.position,
    required super.size,
    required this.speed,
    required this.health,
    required this.scoreValue,
    required this.variant,
    required this.movePattern,
    this.isBoss = false,
  });

  final double speed;
  double health;
  final int scoreValue;
  final int variant;
  final String movePattern;
  final bool isBoss;
  double fireCooldown = 0;
  double _phase = 0;

  Vector2 get velocity {
    final base = Vector2(0, speed);
    if (movePattern == 'zigzag') {
      final sway = math.sin(_phase * 3.5) * 90;
      return Vector2(sway * 0.12, speed);
    }
    if (movePattern == 'strafe') {
      final sway = math.sin(_phase * 2.3) * 85;
      return Vector2(sway * 0.16, speed * 0.85);
    }
    if (movePattern == 'Boss' || movePattern == 'boss') {
      return Vector2(math.sin(_phase * 2.0) * 70, 55);
    }
    return base;
  }

  bool get hasReachedPlayer {
    final game = parent as GalaxyDefenderGame?;
    if (game == null) return false;
    return position.y > GameConfig.worldHeight - 120;
  }

  void takeDamage(double amount) {
    health -= amount;
    if (health <= 0 && isBoss) {
      final game = parent as GalaxyDefenderGame?;
      game?._bossActive = false;
      game?._score += 1000;
      game?._wave = 9;
      game?.onGameWon?.call();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _phase += dt;
    final game = parent as GalaxyDefenderGame?;
    if (game == null) return;
    fireCooldown -= dt;
    if (isBoss && fireCooldown <= 0) {
      fireCooldown = 1.3;
      game.spawnEnemyShot(this);
      game.spawnEnemyShot(this);
    }
    if (!isBoss && fireCooldown <= 0 && position.y > 20) {
      fireCooldown = 1.6 + _phase;
      if (game._random.nextDouble() < 0.75) {
        game.spawnEnemyShot(this);
      }
    }
  }
}

class Projectile extends PositionComponent {
  Projectile({
    required super.position,
    required this.velocity,
    required this.damage,
    required this.color,
    required this.radius,
  });

  final Vector2 velocity;
  final int damage;
  final Color color;
  final double radius;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()..color = color;
    canvas.drawCircle(Offset.zero, radius, paint);
  }
}

class PowerUp extends PositionComponent {
  PowerUp({
    required super.position,
    required this.kind,
    required super.size,
  });

  final String kind;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()..color = _colorForKind(kind);
    canvas.drawCircle(Offset.zero, 12, paint);
  }

  Color _colorForKind(String kind) {
    switch (kind) {
      case 'health':
        return const Color(0xFF4CAF50);
      case 'shield':
        return const Color(0xFF5C6BC0);
      case 'rapid':
        return const Color(0xFFFFD54F);
      case 'score':
        return const Color(0xFFE91E63);
      default:
        return const Color(0xFFB0BEC5);
    }
  }
}

class Explosion extends PositionComponent {
  Explosion({
    required super.position,
    required this.radius,
    required this.color,
  });

  final double radius;
  final Color color;
  double life = 0.4;

  void updateLife(double dt) {
    life -= dt;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()
      ..color = color.withOpacity(life * 2.5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, radius * (1 - life * 0.8), paint);
  }
}

class Starfield extends PositionComponent {
  final List<_Star> _stars = [];

  @override
  Future<void> onLoad() async {
    for (var i = 0; i < 110; i++) {
      _stars.add(
        _Star(
          Vector2(
            (i * 17.3) % GameConfig.worldWidth,
            (i * 23.7) % GameConfig.worldHeight,
          ),
          1.8 + ((i % 5) * 0.5),
          22 + (i % 5) * 10,
        ),
      );
    }
  }

  @override
  void render(Canvas canvas) {
    final background = Paint()..color = const Color(0xFF040816);
    canvas.drawRect(Rect.fromLTWH(0, 0, GameConfig.worldWidth, GameConfig.worldHeight), background);

    for (final star in _stars) {
      final paint = Paint()..color = star.color.withOpacity(0.7);
      canvas.drawCircle(Offset(star.position.x, star.position.y), star.size, paint);
    }
  }

  @override
  void update(double dt) {
    for (final star in _stars) {
      star.position.y += star.speed * dt;
      if (star.position.y > GameConfig.worldHeight) {
        star.position.y = 0;
        star.position.x = (star.position.x + 21) % GameConfig.worldWidth;
      }
    }
  }
}

class _Star {
  _Star(this.position, this.size, this.speed)
      : color = const Color(0xFF9AD6FF).withOpacity(0.5 + (size / 25));

  final Vector2 position;
  final double size;
  final double speed;
  final Color color;
}
