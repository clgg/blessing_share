import 'package:blessing_share/app/app_theme.dart';
import 'package:blessing_share/core/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: '关于我们',
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 44,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.volunteer_activism_rounded,
                    color: Colors.white, size: 44),
              ),
              const SizedBox(height: 20),
              Text('祝福素材分享', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text('框架演示版 1.0.0', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 18),
              Text(
                '用简单清晰的方式，帮助每个人把祝福送给重要的人。',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
