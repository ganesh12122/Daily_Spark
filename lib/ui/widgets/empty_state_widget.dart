import 'package:flutter/material.dart';

class EmptyStateWidget extends StatefulWidget {
  const EmptyStateWidget({super.key});

  @override
  State<EmptyStateWidget> createState() => EmptyStateWidgetState();
}

class EmptyStateWidgetState extends State<EmptyStateWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _colorAnimation = ColorTween(
      begin: Colors.orange,
      end: Colors.red,
    ).animate(
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
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Icon(
                    Icons.local_fire_department,
                    size: 100,
                    color: _colorAnimation.value,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'No disciplines yet!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Tap the + button to add your first discipline.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}