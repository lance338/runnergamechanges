import 'package:flame/components.dart';

/// Shared depth for a forward-facing Flame runner.
///
/// Every coin, hazard, dash, and roadside building uses one distance,
/// measured in world units ahead of the player. [project] turns that
/// distance into a screen point and a scale. The sky can stay a normal
/// [SpriteComponent]. It does not share this distance.
///
/// Call [resize] from `FlameGame.onGameResize`.
class Depth {
  static const double near = 780;
  static const double runSpeed = 1500 / 5.8 * 2.6;

  static double centerX = 200;
  static double horizonY = 180;
  static double groundY = 640;
  static double halfWidth = 160;

  static void resize(Vector2 size) {
    centerX = size.x / 2;
    horizonY = size.y * 0.4;
    groundY = size.y;
    halfWidth = size.x * 0.52;
  }

  static double scaleAt(double distance) => near / (near + distance);

  static Vector2 project(double laneOffset, double distance) {
    final s = scaleAt(distance);
    return Vector2(
      centerX + laneOffset * s,
      horizonY + (groundY - horizonY) * s,
    );
  }
}

/// Goal sprite. [laneOffset] is the pixel offset from the road center
/// when the sprite reaches the player (distance 0).
///
/// [anchor] is [Anchor.bottomCenter], so the feet stay on the road point
/// while [scale] changes. [SpriteComponent] defaults to [Anchor.topLeft];
/// leaving that default makes a growing sprite slide down and off its lane.
class DepthSprite extends SpriteComponent {
  DepthSprite({
    required Sprite sprite,
    required Vector2 baseSize,
    required this.laneOffset,
    required this.distance,
  }) : super(
          sprite: sprite,
          size: baseSize,
          anchor: Anchor.bottomCenter,
        );

  /// Pixels from the road center at distance 0. Constant for the sprite's life.
  final double laneOffset;

  /// World units ahead of the player. Decreases by [Depth.runSpeed].
  double distance;

  @override
  void update(double dt) {
    super.update(dt);
    distance -= Depth.runSpeed * dt;
    final s = Depth.scaleAt(distance);
    scale = Vector2.all(s);
    position = Depth.project(laneOffset, distance);
    // Nearer sprites draw above farther ones.
    priority = -distance.round();
    if (distance < -40) removeFromParent();
  }
}

/// Current runner, kept here so the two updates can be compared.
///
/// This steps a 0–1 screen progress by a constant amount each frame, then
/// copies that progress into both Y and scale. Pixel speed never increases,
/// so the sprite looks slower as it gets large, and the default top-left
/// anchor makes it grow off the lane.
class ScreenStepSprite extends SpriteComponent {
  ScreenStepSprite({
    required Sprite sprite,
    required Vector2 baseSize,
    required this.laneOffset,
  }) : super(sprite: sprite, size: baseSize);

  final double laneOffset;
  double screenT = 0;

  @override
  void update(double dt) {
    super.update(dt);
    screenT += dt / 5.8;
    final t = screenT.clamp(0.0, 1.0);
    scale = Vector2.all(t);
    position = Vector2(
      Depth.centerX + laneOffset * t,
      Depth.horizonY + (Depth.groundY - Depth.horizonY) * t,
    );
    if (screenT > 1) removeFromParent();
  }
}
