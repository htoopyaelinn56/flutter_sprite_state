import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui';

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
    final palette = <Color>[
      Colors.deepOrangeAccent,
      Colors.orangeAccent,
      Colors.amber,
      Colors.yellow,
    ];

    final burst = Particle.generate(
      count: 28,
      lifespan: 0.45,
      generator: (_) {
        final angle = random.nextDouble() * pi * 2;
        final speed = 140 + random.nextDouble() * 240;
        final velocity = Vector2(cos(angle), sin(angle)) * speed;
        final color = palette[random.nextInt(palette.length)];

        return AcceleratedParticle(
          speed: velocity,
          acceleration: -velocity * 3,
          child: CircleParticle(
            radius: 2 + random.nextDouble() * 3.5,
            paint: Paint()
              ..color = color.withAlpha(220)
              ..blendMode = BlendMode.plus,
          ),
        );
      },
    );

    final shockwave = ComputedParticle(
      lifespan: 0.35,
      renderer: (canvas, particle) {
        final eased = Curves.easeOut.transform(particle.progress);
        final radius = lerpDouble(8, 70, eased)!;
        final stroke = lerpDouble(4, 0.5, eased)!;
        final paint = Paint()
          ..color = Colors.deepOrange.withOpacity(1 - eased)
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..blendMode = BlendMode.plus;
        canvas.drawCircle(Offset.zero, radius, paint);
      },
    );

    parentComponent.addAll([
      ParticleSystemComponent(
        position: worldPosition,
        particle: burst,
        priority: 2,
      ),
      ParticleSystemComponent(
        position: worldPosition,
        particle: shockwave,
        priority: 3,
      ),
    ]);
  }
}
