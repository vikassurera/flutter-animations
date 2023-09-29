import 'dart:math';

import 'package:flutter/material.dart';

enum CircleSide {
  left,
  right,
}

extension ToPath on CircleSide {
  Path toPath(Size size) {
    final path = Path();

    late Offset offset;
    late bool clockwise;

    switch (this) {
      case CircleSide.left:
        path.moveTo(size.width, 0);
        offset = Offset(size.width, size.height);
        clockwise = false;
        break;
      case CircleSide.right:
        offset = Offset(0, size.height);
        clockwise = true;
        break;
    }

    path.arcToPoint(
      offset,
      radius: Radius.elliptical(size.width / 2, size.height / 2),
      clockwise: clockwise,
    );

    path.close();
    return path;
  }
}

class HalfCircleClipper extends CustomClipper<Path> {
  const HalfCircleClipper({
    required this.side,
  });

  final CircleSide side;

  @override
  Path getClip(Size size) {
    return side.toPath(size);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}

extension on VoidCallback {
  Future<void> delayed(Duration duration) => Future.delayed(duration, this);
}

class ChainedAnimation extends StatefulWidget {
  const ChainedAnimation({super.key});

  @override
  State<ChainedAnimation> createState() => _ChainedAnimationState();
}

class _ChainedAnimationState extends State<ChainedAnimation>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: -pi / 2,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.bounceOut,
    ));

    _flipController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _flipAnimation = Tween<double>(
      begin: 0,
      end: pi,
    ).animate(CurvedAnimation(
      parent: _flipController,
      curve: Curves.bounceOut,
    ));

    _rotationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _flipAnimation = Tween<double>(
          begin: _flipAnimation.value,
          end: _flipAnimation.value + pi,
        ).animate(CurvedAnimation(
          parent: _flipController,
          curve: Curves.bounceOut,
        ));

        _flipController
          ..reset()
          ..forward();
      }
    });

    _flipController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _rotationAnimation = Tween<double>(
          begin: _rotationAnimation.value,
          end: _rotationAnimation.value == 0 ? -pi / 2 : 0,
        ).animate(CurvedAnimation(
          parent: _rotationController,
          curve: Curves.bounceOut,
        ));

        _rotationController
          ..reset()
          ..forward();
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _rotationController
      ..reset()
      ..forward.delayed(const Duration(seconds: 1));

    return Scaffold(
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _flipAnimation,
          builder: (context, child) => Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..rotateX(_flipAnimation.value),
            child: AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) => Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..rotateZ(_rotationAnimation.value),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipPath(
                      clipper: const HalfCircleClipper(side: CircleSide.left),
                      child: Container(
                        height: 100,
                        width: 100,
                        color: Colors.deepPurple,
                      ),
                    ),
                    ClipPath(
                      clipper: const HalfCircleClipper(side: CircleSide.right),
                      child: Container(
                        height: 100,
                        width: 100,
                        color: Colors.yellow,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
