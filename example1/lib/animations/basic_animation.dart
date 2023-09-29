import 'dart:math';
import 'package:flutter/material.dart';

class BasicAnimation extends StatefulWidget {
  const BasicAnimation({super.key});

  @override
  State<BasicAnimation> createState() => _BasicAnimationState();
}

class _BasicAnimationState extends State<BasicAnimation>
    with SingleTickerProviderStateMixin {
  // Declare the animation controller and animation
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Initialize the animation
    _animation = Tween<double>(begin: 0, end: 2 * pi).animate(_controller);

    // Start the animation
    _controller.repeat();
  }

  @override
  void dispose() {
    super.dispose();

    // Dispose the animation controller
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        // Wrap the AnimatedBuilder with a Container
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            // Return a Transform widget
            return Transform(
              alignment: Alignment.center,
              // Rotate the child by the current value of the animation
              transform: Matrix4.identity()..rotateZ(_animation.value),
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
