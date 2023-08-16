import 'package:flutter/material.dart';
import 'package:instagram_clone/views/components/animations/animation_views.dart';

class EmptyContentsWithTextAnimationView extends StatelessWidget {
  final String text;
  const EmptyContentsWithTextAnimationView({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                text,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white54,
                      height: 1.3,
                    ),
              ),
              const EmptyContentsAnimationView(),
            ],
          ),
        ),
      ),
    );
  }
}
