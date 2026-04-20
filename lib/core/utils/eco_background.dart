import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

enum BackgroundType {
  login,
  dashboard,
  appliances,
  achievements,
  reports,
}

class NatureParticle {
  double x;
  double y;
  final double size;
  final double speed;
  final int type;
  final double opacity;

  NatureParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.type,
    required this.opacity,
  });
}

class ConfettiParticle {
  double x;
  double y;
  final double size;
  final double speed;
  final Color color;
  final double rotation;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.color,
    required this.rotation,
  });
}

class DataParticle {
  double x;
  double y;
  final double size;
  final double speed;
  final int type;
  final double opacity;

  DataParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.type,
    required this.opacity,
  });
}

class NatureParticlePainter extends CustomPainter {
  final List<NatureParticle> particles;
  final double progress;
  final BackgroundType backgroundType;

  NatureParticlePainter({
    required this.particles,
    required this.progress,
    required this.backgroundType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final yOffset = (progress * particle.speed + particle.y) % 1.0;
      final xOffset = sin(progress * 2 * pi + particle.x * 10) * 0.02;

      final x = (particle.x + xOffset) * size.width;
      final y = yOffset * size.height;

      final paint = Paint()
        ..color = _getParticleColor(particle.type).withValues(alpha: particle.opacity)
        ..style = PaintingStyle.fill;

      switch (particle.type) {
        case 0:
          _drawLeaf(canvas, x, y, particle.size, paint);
          break;
        case 1:
          _drawFlower(canvas, x, y, particle.size / 2, paint);
          break;
        case 2:
          _drawSparkle(canvas, x, y, particle.size / 2, paint);
          break;
        case 3:
          _drawCircle(canvas, x, y, particle.size / 4, paint);
          break;
      }
    }
  }

  void _drawLeaf(Canvas canvas, double x, double y, double size, Paint paint) {
    final path = Path();
    path.moveTo(x, y - size / 2);
    path.quadraticBezierTo(x + size / 2, y - size / 4, x, y + size / 2);
    path.quadraticBezierTo(x - size / 2, y - size / 4, x, y - size / 2);
    canvas.drawPath(path, paint);
  }

  void _drawFlower(Canvas canvas, double x, double y, double radius, Paint paint) {
    for (int i = 0; i < 5; i++) {
      final angle = (i * 72) * pi / 180;
      final petalX = x + cos(angle) * radius;
      final petalY = y + sin(angle) * radius;
      canvas.drawCircle(Offset(petalX, petalY), radius * 0.6, paint);
    }
    canvas.drawCircle(Offset(x, y), radius * 0.4, paint..color = const Color(0xFFFFEB3B));
  }

  void _drawSparkle(Canvas canvas, double x, double y, double size, Paint paint) {
    final path = Path();
    path.moveTo(x, y - size);
    path.lineTo(x + size * 0.2, y - size * 0.2);
    path.lineTo(x + size, y);
    path.lineTo(x + size * 0.2, y + size * 0.2);
    path.lineTo(x, y + size);
    path.lineTo(x - size * 0.2, y + size * 0.2);
    path.lineTo(x - size, y);
    path.lineTo(x - size * 0.2, y - size * 0.2);
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawCircle(Canvas canvas, double x, double y, double radius, Paint paint) {
    canvas.drawCircle(Offset(x, y), radius, paint);
  }

  Color _getParticleColor(int type) {
    switch (backgroundType) {
      case BackgroundType.login:
      case BackgroundType.dashboard:
        switch (type) {
          case 0:
            return const Color(0xFF4CAF50);
          case 1:
            return const Color(0xFF81C784);
          case 2:
            return const Color(0xFFA5D6A7);
          case 3:
            return const Color(0xFF66BB6A);
          default:
            return const Color(0xFF4CAF50);
        }
      case BackgroundType.appliances:
        switch (type) {
          case 0:
            return const Color(0xFF64B5F6);
          case 1:
            return const Color(0xFF42A5F5);
          case 2:
            return const Color(0xFF1E88E5);
          case 3:
            return const Color(0xFF90CAF9);
          default:
            return const Color(0xFF64B5F6);
        }
      case BackgroundType.achievements:
        switch (type) {
          case 0:
            return const Color(0xFFFFD700);
          case 1:
            return const Color(0xFFFFC107);
          case 2:
            return const Color(0xFFFFEB3B);
          case 3:
            return const Color(0xFFFF9800);
          default:
            return const Color(0xFFFFD700);
        }
      case BackgroundType.reports:
        switch (type) {
          case 0:
            return const Color(0xFFAB47BC);
          case 1:
            return const Color(0xFF9C27B0);
          case 2:
            return const Color(0xFFE040FB);
          case 3:
            return const Color(0xFFBA68C8);
          default:
            return const Color(0xFFAB47BC);
        }
    }
  }

  @override
  bool shouldRepaint(NatureParticlePainter oldDelegate) => true;
}

class EcoBackground extends StatefulWidget {
  final Widget child;
  final bool enableMotion;
  final BackgroundType backgroundType;

  const EcoBackground({
    super.key,
    required this.child,
    this.enableMotion = true,
    this.backgroundType = BackgroundType.dashboard,
  });

  @override
  State<EcoBackground> createState() => _EcoBackgroundState();
}

class _EcoBackgroundState extends State<EcoBackground> with TickerProviderStateMixin {
  late AnimationController _controller;
  final List<NatureParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    if (widget.enableMotion) {
      _initParticles();
      _controller.repeat();
    }
  }

  void _initParticles() {
    for (int i = 0; i < 30; i++) {
      _particles.add(NatureParticle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 25 + 10,
        speed: _random.nextDouble() * 0.4 + 0.1,
        type: _random.nextInt(4),
        opacity: _random.nextDouble() * 0.5 + 0.2,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Color> _getGradientColors() {
    switch (widget.backgroundType) {
      case BackgroundType.login:
        return [
          const Color(0xFF0D1F0D),
          const Color(0xFF1A3A1A),
          const Color(0xFF0D1F0D),
        ];
      case BackgroundType.dashboard:
        return [
          const Color(0xFF0D1F0D),
          const Color(0xFF1A3A1A),
          const Color(0xFF0D1F0D),
        ];
      case BackgroundType.appliances:
        return [
          const Color(0xFF0A1929),
          const Color(0xFF132F4C),
          const Color(0xFF0A1929),
        ];
      case BackgroundType.achievements:
        return [
          const Color(0xFF1A1A00),
          const Color(0xFF2D2D00),
          const Color(0xFF1A1A00),
        ];
      case BackgroundType.reports:
        return [
          const Color(0xFF0D0D1A),
          const Color(0xFF1A1A2E),
          const Color(0xFF0D0D1A),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getGradientColors();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ),
      ),
      child: Stack(
        children: [
          if (widget.enableMotion)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: NatureParticlePainter(
                    particles: _particles,
                    progress: _controller.value,
                    backgroundType: widget.backgroundType,
                  ),
                  size: Size.infinite,
                );
              },
            ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.5),
                    Colors.black.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}

class AchievementsBackground extends StatefulWidget {
  final Widget child;
  final bool enableMotion;

  const AchievementsBackground({
    super.key,
    required this.child,
    this.enableMotion = true,
  });

  @override
  State<AchievementsBackground> createState() => _AchievementsBackgroundState();
}

class _AchievementsBackgroundState extends State<AchievementsBackground> with TickerProviderStateMixin {
  late AnimationController _controller;
  final List<ConfettiParticle> _particles = [];
  final Random _random = Random();

  final List<Color> _confettiColors = [
    const Color(0xFFFFD700),
    const Color(0xFFFFC107),
    const Color(0xFFFFEB3B),
    const Color(0xFFFF9800),
    const Color(0xFFFF5722),
    const Color(0xFFE91E63),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );

    if (widget.enableMotion) {
      _initParticles();
      _controller.repeat();
    }
  }

  void _initParticles() {
    for (int i = 0; i < 50; i++) {
      _particles.add(ConfettiParticle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 12 + 6,
        speed: _random.nextDouble() * 0.4 + 0.15,
        color: _confettiColors[_random.nextInt(_confettiColors.length)],
        rotation: _random.nextDouble() * 360,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1A1A00),
            Color(0xFF2D2D00),
            Color(0xFF1A1A00),
          ],
        ),
      ),
      child: Stack(
        children: [
          if (widget.enableMotion)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: ConfettiPainter(
                    particles: _particles,
                    progress: _controller.value,
                  ),
                  size: Size.infinite,
                );
              },
            ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.5),
                    Colors.black.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;

  ConfettiPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final yOffset = (progress * particle.speed + particle.y) % 1.0;
      final xOffset = sin(progress * 3 * pi + particle.x * 20) * 0.03;

      final x = (particle.x + xOffset) * size.width;
      final y = yOffset * size.height;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate((progress * 360 + particle.rotation) * pi / 180);

      final paint = Paint()
        ..color = particle.color.withValues(alpha: 0.7)
        ..style = PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: particle.size, height: particle.size / 2),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) => true;
}

class ReportsBackground extends StatefulWidget {
  final Widget child;
  final bool enableMotion;

  const ReportsBackground({
    super.key,
    required this.child,
    this.enableMotion = true,
  });

  @override
  State<ReportsBackground> createState() => _ReportsBackgroundState();
}

class _ReportsBackgroundState extends State<ReportsBackground> with TickerProviderStateMixin {
  late AnimationController _controller;
  final List<DataParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );

    if (widget.enableMotion) {
      _initParticles();
      _controller.repeat();
    }
  }

  void _initParticles() {
    for (int i = 0; i < 35; i++) {
      _particles.add(DataParticle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 20 + 8,
        speed: _random.nextDouble() * 0.3 + 0.1,
        type: _random.nextInt(3),
        opacity: _random.nextDouble() * 0.4 + 0.15,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0D0D1A),
            Color(0xFF1A1A2E),
            Color(0xFF0D0D1A),
          ],
        ),
      ),
      child: Stack(
        children: [
          if (widget.enableMotion)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: DataVisualizationPainter(
                    particles: _particles,
                    progress: _controller.value,
                  ),
                  size: Size.infinite,
                );
              },
            ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.5),
                    Colors.black.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}

class DataVisualizationPainter extends CustomPainter {
  final List<DataParticle> particles;
  final double progress;

  DataVisualizationPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final yOffset = (progress * particle.speed + particle.y) % 1.0;
      final xOffset = sin(progress * 2 * pi + particle.x * 10) * 0.015;

      final x = (particle.x + xOffset) * size.width;
      final y = yOffset * size.height;

      final paint = Paint()
        ..color = _getParticleColor(particle.type).withValues(alpha: particle.opacity)
        ..style = PaintingStyle.fill;

      switch (particle.type) {
        case 0:
          _drawBar(canvas, x, y, particle.size, paint);
          break;
        case 1:
          _drawLine(canvas, x, y, particle.size, paint);
          break;
        case 2:
          _drawDot(canvas, x, y, particle.size / 3, paint);
          break;
      }
    }
  }

  void _drawBar(Canvas canvas, double x, double y, double size, Paint paint) {
    canvas.drawRect(
      Rect.fromLTWH(x - size / 4, y - size / 2, size / 2, size),
      paint,
    );
  }

  void _drawLine(Canvas canvas, double x, double y, double size, Paint paint) {
    final path = Path();
    path.moveTo(x - size / 2, y);
    path.lineTo(x, y - size / 2);
    path.lineTo(x + size / 2, y);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawPath(path, paint);
    paint.style = PaintingStyle.fill;
  }

  void _drawDot(Canvas canvas, double x, double y, double radius, Paint paint) {
    canvas.drawCircle(Offset(x, y), radius, paint);
  }

  Color _getParticleColor(int type) {
    switch (type) {
      case 0:
        return const Color(0xFFAB47BC);
      case 1:
        return const Color(0xFF9C27B0);
      case 2:
        return const Color(0xFFE040FB);
      default:
        return const Color(0xFFAB47BC);
    }
  }

  @override
  bool shouldRepaint(DataVisualizationPainter oldDelegate) => true;
}

class AppliancesBackground extends StatefulWidget {
  final Widget child;
  final bool enableMotion;

  const AppliancesBackground({
    super.key,
    required this.child,
    this.enableMotion = true,
  });

  @override
  State<AppliancesBackground> createState() => _AppliancesBackgroundState();
}

class _AppliancesBackgroundState extends State<AppliancesBackground> with TickerProviderStateMixin {
  late AnimationController _controller;
  final List<NatureParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    if (widget.enableMotion) {
      _initParticles();
      _controller.repeat();
    }
  }

  void _initParticles() {
    for (int i = 0; i < 35; i++) {
      _particles.add(NatureParticle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 25 + 10,
        speed: _random.nextDouble() * 0.4 + 0.1,
        type: _random.nextInt(4),
        opacity: _random.nextDouble() * 0.5 + 0.2,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0A1929),
            Color(0xFF132F4C),
            Color(0xFF0A1929),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 50,
            right: 30,
            child: _buildCloud(),
          ),
          Positioned(
            top: 100,
            left: 40,
            child: _buildSun(),
          ),
          Positioned(
            bottom: 150,
            right: 50,
            child: _buildCloud(small: true),
          ),
          if (widget.enableMotion)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: NatureParticlePainter(
                    particles: _particles,
                    progress: _controller.value,
                    backgroundType: BackgroundType.appliances,
                  ),
                  size: Size.infinite,
                );
              },
            ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.5),
                    Colors.black.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }

  Widget _buildCloud({bool small = false}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(seconds: 3),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(sin(value * 2 * 3.14159) * 10, 0),
          child: child,
        );
      },
      child: Container(
        width: small ? 60 : 100,
        height: small ? 30 : 50,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(50),
        ),
      ),
    );
  }

  Widget _buildSun() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(seconds: 4),
      builder: (context, value, child) {
        return Transform.rotate(
          angle: value * 2 * 3.14159,
          child: child,
        );
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.yellow.withValues(alpha: 0.2),
          boxShadow: [
            BoxShadow(
              color: Colors.yellow.withValues(alpha: 0.1),
              blurRadius: 30,
              spreadRadius: 10,
            ),
          ],
        ),
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class AnimatedTree extends StatefulWidget {
  final double height;
  final double width;

  const AnimatedTree({
    super.key,
    this.height = 100,
    this.width = 80,
  });

  @override
  State<AnimatedTree> createState() => _AnimatedTreeState();
}

class _AnimatedTreeState extends State<AnimatedTree> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _swayAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _swayAnimation = Tween<double>(begin: -0.02, end: 0.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _swayAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _swayAnimation.value,
          alignment: Alignment.bottomCenter,
          child: CustomPaint(
            size: Size(widget.width, widget.height),
            painter: TreePainter(),
          ),
        );
      },
    );
  }
}

class TreePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final trunkPaint = Paint()
      ..color = const Color(0xFF795548)
      ..style = PaintingStyle.fill;

    final leafPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.fill;

    final trunkRect = Rect.fromLTWH(size.width * 0.4, size.height * 0.5, size.width * 0.2, size.height * 0.5);
    canvas.drawRect(trunkRect, trunkPaint);

    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.3), size.width * 0.3, leafPaint);
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.4), size.width * 0.25, leafPaint);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.4), size.width * 0.25, leafPaint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.15), size.width * 0.25, leafPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class FloatingLeaf extends StatefulWidget {
  final IconData icon;
  final Duration duration;
  final double size;
  final Color? color;

  const FloatingLeaf({
    super.key,
    this.icon = Icons.eco,
    this.duration = const Duration(seconds: 4),
    this.size = 24,
    this.color,
  });

  @override
  State<FloatingLeaf> createState() => _FloatingLeafState();
}

class _FloatingLeafState extends State<FloatingLeaf> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();

    _floatAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(begin: -0.1, end: 0.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            sin(_floatAnimation.value * pi * 2) * 10,
            -_floatAnimation.value * 30,
          ),
          child: Transform.rotate(
            angle: _rotateAnimation.value,
            child: Icon(
              widget.icon,
              size: widget.size,
              color: (widget.color ?? const Color(0xFF4CAF50)).withValues(alpha: 0.6),
            ),
          ),
        );
      },
    );
  }
}

class FloatingCircle extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;
  final double distance;

  const FloatingCircle({
    super.key,
    this.size = 20,
    this.color = const Color(0xFF81C784),
    this.duration = const Duration(seconds: 4),
    this.distance = 30,
  });

  @override
  State<FloatingCircle> createState() => _FloatingCircleState();
}

class _FloatingCircleState extends State<FloatingCircle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_animation.value * widget.distance),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color.withValues(alpha: 0.3),
            ),
          ),
        );
      },
    );
  }
}
