import 'package:flutter/material.dart';
import '../../app_colors.dart';
import '../shared/app_card.dart';

/// NewsScreen üstündeki hızlı işlemler kartı (statik, ikon grid).
class QuickActionsCard extends StatelessWidget {
  const QuickActionsCard({super.key});

  static const List<Map<String, dynamic>> _actions = [
    {'icon': '📋', 'label': 'Arıza Bildir', 'color': Color(0xFFEBF5FF)},
    {'icon': '📞', 'label': 'Çağrı Merkezi', 'color': Color(0xFFE8F9F0)},
    {'icon': '🗺️', 'label': 'Şebeke Haritası', 'color': Color(0xFFFFF6E8)},
    {'icon': '📊', 'label': 'Su Kalitesi', 'color': Color(0xFFF3F0FF)},
  ];

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hızlı İşlemler',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _actions.map((action) {
              return _QuickActionItem(
                icon: action['icon'] as String,
                label: action['label'] as String,
                bgColor: action['color'] as Color,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${action['label']} açılıyor…'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final String icon;
  final String label;
  final Color bgColor;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.5), width: 1),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 70,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
