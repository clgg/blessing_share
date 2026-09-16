import 'package:blessing_share/app/app_theme.dart';
import 'package:flutter/material.dart';

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = <({String label, IconData icon, Key key})>[
    (label: '首页', icon: Icons.home_rounded, key: Key('bottom-nav-home')),
    (
      label: '收藏',
      icon: Icons.star_rounded,
      key: Key('bottom-nav-favorites'),
    ),
    (label: '我的', icon: Icons.person_rounded, key: Key('bottom-nav-profile')),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 76,
          child: Row(
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final selected = currentIndex == index;
              final color =
                  selected ? AppColors.primary : AppColors.textSecondary;

              return Expanded(
                child: Semantics(
                  selected: selected,
                  button: true,
                  label: selected ? '${item.label}，已选中' : item.label,
                  excludeSemantics: true,
                  child: InkWell(
                    key: item.key,
                    onTap: () => onTap(index),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(item.icon, color: color, size: 28),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: TextStyle(
                            color: color,
                            fontSize: 17,
                            height: 1.15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
