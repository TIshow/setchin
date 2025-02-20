import 'package:flutter/material.dart';

class FloatingButtons extends StatelessWidget {
  final VoidCallback onCurrentLocationPressed;
  final VoidCallback onReloadPressed;
  final VoidCallback onZoomInPressed;
  final VoidCallback onZoomOutPressed;

  const FloatingButtons({
    super.key,
    required this.onCurrentLocationPressed,
    required this.onReloadPressed,
    required this.onZoomInPressed,
    required this.onZoomOutPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          bottom: 90,
          right: 16,
          child: FloatingActionButton(
            onPressed: onCurrentLocationPressed,
            child: const Icon(Icons.my_location),
          ),
        ),
        Positioned(
          bottom: 160,
          right: 16,
          child: FloatingActionButton(
            onPressed: onReloadPressed,
            child: const Icon(Icons.refresh),
          ),
        ),
        Positioned(
          top: 120,
          left: 16,
          child: Column(
            children: [
              FloatingActionButton(
                mini: true,
                onPressed: onZoomInPressed,
                child: const Icon(Icons.add),
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                mini: true,
                onPressed: onZoomOutPressed,
                child: const Icon(Icons.remove),
              ),
            ],
          ),
        ),
      ],
    );
  }
}