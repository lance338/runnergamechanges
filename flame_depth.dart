import 'package:flame/components.dart';

/// Flame reference for the playable demo in `index.html`.
///
/// Both views share one distance and one clock. An item is spawned at
/// [Depth.viewZ] and removed just past [Depth.playerZ]. The trip takes the
/// same time either way. Only the function that turns that distance into a
/// screen scale is different.
///
/// `z` is world units ahead of the camera. Larger `z` is farther up the road.
/// The avatar stands at [Depth.playerZ], not at 0.
///
/// Call [Depth.resize] from `FlameGame.onGameResize`.
class Depth {
  static const double near = 420;
  static const double viewZ = 2300;
  static const double playerZ = 90;
  static const double runSpeed = 520;

  /// Full sprite height at scale 1. The demo draws coins at 99, bats at 203,
  /// and suns at 240, then multiplies by the scale below.
  static double centerX = 0;
  static double horizonY = 0;
  static double groundY = 0;
  static double roadHalf = 0;

  static void resize(Vector2 size) {
    centerX = size.x / 2;
    horizonY = size.y * 0.28;
    groundY = size.y;
    roadHalf = size.x * 0.52;
  }

  /// Horizon spawn. Pixel speed is slow far away and fast beside the pin.
  static double horizonScale(double z) => near / (near + z);

  /// Screen spawn. Equal world steps are equal pixel steps.
  /// `t` is 1 when the item reaches the avatar, so the hit and the picture match.
  static double screenScale(double z) {
    final farS = near / (near + viewZ);
    final pinS = near / (near + playerZ);
    final t = ((viewZ - z) / (viewZ - playerZ)).clamp(0.0, 1.08);
    return farS + (pinS - farS) * t;
  }

  /// [lane] is a road coordinate, not pixels. The demo uses -0.64, 0, and 0.64.
  static Vector2 place(double lane, double scale) {
    return Vector2(
      centerX + lane * roadHalf * scale,
      horizonY + (groundY - horizonY) * scale,
    );
  }
}

/// Goal. Road dashes and roadside props use this same scale and the same
/// moving distance. The sky stays a normal sprite and does not.
///
/// [anchor] is [Anchor.bottomCenter], so the feet stay on the road point while
/// the sprite grows. [SpriteComponent] defaults to [Anchor.topLeft], which
/// slides a growing sprite off its lane.
class HorizonSprite extends SpriteComponent {
  HorizonSprite({
    required Sprite sprite,
    required Vector2 baseSize,
    required this.lane,
    required this.distance,
  }) : super(
          sprite: sprite,
          size: baseSize,
          anchor: Anchor.bottomCenter,
        );

  final double lane;

  /// World units ahead of the camera. Decreases by [Depth.runSpeed].
  double distance;

  @override
  void update(double dt) {
    super.update(dt);
    distance -= Depth.runSpeed * dt;
    final s = Depth.horizonScale(distance);
    scale = Vector2.all(s);
    position = Depth.place(lane, s);
    priority = -distance.round();
    if (distance < 8) removeFromParent();
  }
}

/// Comparison view. Keep the road on [HorizonSprite] with the camera held
/// still. Only the item uses [Depth.screenScale].
///
/// This subtracts the same [Depth.runSpeed] from the same distance as
/// [HorizonSprite], so spawn-to-despawn time matches. An older sketch stepped
/// a 0–1 screen timer on its own clock. That is not what the demo does.
class ScreenSpawnSprite extends SpriteComponent {
  ScreenSpawnSprite({
    required Sprite sprite,
    required Vector2 baseSize,
    required this.lane,
    required this.distance,
  }) : super(
          sprite: sprite,
          size: baseSize,
          anchor: Anchor.bottomCenter,
        );

  final double lane;
  double distance;

  @override
  void update(double dt) {
    super.update(dt);
    distance -= Depth.runSpeed * dt;
    final s = Depth.screenScale(distance);
    scale = Vector2.all(s);
    position = Depth.place(lane, s);
    priority = -distance.round();
    if (distance < 8) removeFromParent();
  }
}
