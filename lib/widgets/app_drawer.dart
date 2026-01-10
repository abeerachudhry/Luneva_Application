import 'package:flutter/material.dart';
import 'package:luneva_application/theme/app_theme.dart';

class AppDrawer extends StatelessWidget {
  final void Function(String) onSelect;
  const AppDrawer({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: AppTheme.purple),
              child: Row(
                children: [
                  const CircleAvatar(radius: 28, backgroundColor: Colors.white, child: Icon(Icons.person, color: AppTheme.purple)),
                  const SizedBox(width: 12),
                  Text('Luneva', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.restaurant_menu),
              title: const Text('Diet Planner'),
              onTap: () => onSelect('diet'),
            ),
            ListTile(
              leading: const Icon(Icons.fitness_center),
              title: const Text('Physical Trainer'),
              onTap: () => onSelect('trainer'),
            ),
            ListTile(
              leading: const Icon(Icons.self_improvement),
              title: const Text('Stress Handler'),
              onTap: () => onSelect('stress'),
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign out'),
              onTap: () => onSelect('signout'),
            ),
          ],
        ),
      ),
    );
  }
}