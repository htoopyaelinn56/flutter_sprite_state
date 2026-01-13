import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';

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
  }

  void reset() {
    _tapCount = 0;
    current = CatState.idle;
  }

  bool get isDead => current == CatState.dead && animationTicker!.done();
}

