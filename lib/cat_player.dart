import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'dart:math';

enum CatState {
  idle,
  hurt,
  dead,
}

class CatPlayer extends SpriteAnimationGroupComponent<CatState>
    with TapCallbacks {
  int _tapCount = 0;

  CatPlayer() : super(size: Vector2.all(200));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final idleAnimation = await _loadAnimation('Idle', 10);
    final hurtAnimation = await _loadAnimation('Hurt', 10);
    final deadAnimation = await _loadAnimation('Dead', 10, loop: false);

    animations = {
      CatState.idle: idleAnimation,
      CatState.hurt: hurtAnimation,
      CatState.dead: deadAnimation,
    };

    current = CatState.idle;
  }

  Future<SpriteAnimation> _loadAnimation(String state, int frameCount, {bool loop = true}) async {
    final frames = await Future.wait([
      for (var i = 1; i <= frameCount; i++)
        Flame.images.load('cat/$state ($i).png'),
    ]);
    final sprites = frames.map((frame) => Sprite(frame)).toList();
    return SpriteAnimation.spriteList(sprites, stepTime: 0.1, loop: loop);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (current == CatState.dead) {
      return;
    }
    _tapCount++;
    if (_tapCount >= 6) {
      current = CatState.dead;
    } else if (_tapCount >= 3) {
      current = CatState.hurt;
    }

    _spawnBurst(event.canvasPosition);
  }

  void reset() {
    _tapCount = 0;
    current = CatState.idle;
  }

  bool get isDead => current == CatState.dead && animationTicker!.done();

  void _spawnBurst(Vector2 worldPosition) {
    final parentComponent = parent;
    if (parentComponent == null) {
      return;
    }

    final random = Random();
    final particle = Particle.generate(
      count: 18,
      lifespan: 0.35,
      generator: (_) {
        final angle = random.nextDouble() * pi * 2;
        final speed = 80 + random.nextDouble() * 160;
        final velocity = Vector2(cos(angle), sin(angle)) * speed;

        return AcceleratedParticle(
          speed: velocity,
          acceleration: -velocity * 3,
          child: CircleParticle(
            radius: 3 + random.nextDouble() * 2.5,
            paint: Paint()
              ..color = Colors.orangeAccent.withAlpha(200),
          ),
        );
      },
    );

    parentComponent.add(
      ParticleSystemComponent(
        position: worldPosition,
        particle: particle,
        priority: 1,
      ),
    );
  }
}
