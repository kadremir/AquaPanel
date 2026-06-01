import 'package:flutter/material.dart';
import '../../app_colors.dart';
import '../shared/app_card.dart';
import '../shared/section_title.dart';

/// Güncel ayın oda/kullanım bazlı su dağılımını gösteren kart.
/// [currentData]: Supabase 'water_usage' tablosundan gelen en son ay verisi.
///
/// Beklenen JSON alanları (opsiyonel, yoksa örnek veriler kullanılır):
///   - bathroom_m3 (num)
///   - kitchen_m3 (num)
///   - garden_m3 (num)
///   - other_m3 (num)
///   - usage_m3 (num): Toplam (yüzde hesabı için)
class UsageBreakdownCard extends StatelessWidget {
  final Map<String, dynamic>? currentData;

  const UsageBreakdownCard({super.key, this.currentData});

  @override
  Widget build(BuildContext context) {
    final double total =
        double.tryParse(currentData?['usage_m3']?.toString() ?? '0') ?? 0;

    // Tablonuzda oda dağılım sütunları yok, tahmini dağılım göster
    final List<_BreakdownItem> items = [
      _BreakdownItem(
          emoji: '🚿',
          label: 'Banyo',
          value: total * 0.45,
          total: total,
          color: AppColors.blueBright),
      _BreakdownItem(
          emoji: '🍳',
          label: 'Mutfak',
          value: total * 0.30,
          total: total,
          color: AppColors.aqua),
      _BreakdownItem(
          emoji: '🌿',
          label: 'Bahçe',
          value: total * 0.15,
          total: total,
          color: AppColors.greenSave),
      _BreakdownItem(
          emoji: '📦',
          label: 'Diğer',
          value: total * 0.10,
          total: total,
          color: AppColors.textMuted),
    ];

    return AppCard(
      child: Column(
        children: [
          SectionTitle(
            title: 'Kullanım Dağılımı',
            actionLabel: '💡 Tahmini',
            onAction: null,
          ),
          const SizedBox(height: 16),
          // Yatay yığılmış bar
          if (total > 0) ...[
            _StackedBar(items: items),
            const SizedBox(height: 20),
          ],
          // Her oda satırı
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _BreakdownRow(item: item),
              )),
          if (total == 0)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'Bu ay için kullanım verisi bulunamadı.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BreakdownItem {
  final String emoji;
  final String label;
  final double value;
  final double total;
  final Color color;

  const _BreakdownItem({
    required this.emoji,
    required this.label,
    required this.value,
    required this.total,
    required this.color,
  });

  double get ratio => total > 0 ? (value / total).clamp(0.0, 1.0) : 0.0;
  String get percentage =>
      '${(ratio * 100).toStringAsFixed(0)}%';
  String get formatted => '${value.toStringAsFixed(2)} m³';
}

class _StackedBar extends StatelessWidget {
  final List<_BreakdownItem> items;
  const _StackedBar({required this.items});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 12,
        child: Row(
          children: items
              .where((i) => i.ratio > 0)
              .map((i) => Flexible(
                    flex: (i.ratio * 1000).toInt(),
                    child: Container(color: i.color),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final _BreakdownItem item;
  const _BreakdownRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: item.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child:
              Center(child: Text(item.emoji, style: const TextStyle(fontSize: 16))),
        ),
        const SizedBox(width: 12),
        Text(
          item.label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        Text(
          item.formatted,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 42,
          alignment: Alignment.centerRight,
          child: Text(
            item.percentage,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: item.color,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Mini bar
        SizedBox(
          width: 50,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: item.ratio,
              minHeight: 6,
              backgroundColor: AppColors.softBg,
              valueColor: AlwaysStoppedAnimation<Color>(item.color),
            ),
          ),
        ),
      ],
    );
  }
}
