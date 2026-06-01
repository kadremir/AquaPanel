import 'package:flutter/material.dart';
import '../../app_colors.dart';
import '../shared/app_card.dart';
import '../shared/section_title.dart';

/// UsageScreen'de kullanılır. Son 6 ayın m³ kullanımını çubuk grafik olarak gösterir.
/// [monthlyData]: Supabase'den gelen ve UsageScreen tarafından sağlanan liste.
/// Her item şu anahtarları içermelidir: 'month_name' (String), 'usage_m3' (num).
class MonthlyChartCard extends StatelessWidget {
  final List<Map<String, dynamic>> monthlyData;

  const MonthlyChartCard({super.key, required this.monthlyData});

  @override
  Widget build(BuildContext context) {
    if (monthlyData.isEmpty) return const SizedBox.shrink();

    // Maksimum değeri bul (grafik ölçeklendirmesi için)
    final double maxUsage = monthlyData.fold<double>(
      1,
      (prev, item) {
        final val = double.tryParse(item['usage_m3'].toString()) ?? 0;
        return val > prev ? val : prev;
      },
    );

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(
            title: 'Aylık Kullanım',
            actionLabel: '${monthlyData.length} ay',
            onAction: () {},
          ),
          const SizedBox(height: 20),
          // Grafik alanı
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: monthlyData.map((item) {
                final double usage =
                    double.tryParse(item['usage_m3'].toString()) ?? 0;
                final String month = _shortMonth(item['month_name'] ?? '');
                final bool isLast =
                    item == monthlyData.last;

                return _ChartBar(
                  value: usage,
                  maxValue: maxUsage,
                  month: month,
                  isHighlighted: isLast,
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 12),
          // Ortalama göstergesi
          _buildAvgRow(maxUsage),
        ],
      ),
    );
  }

  Widget _buildAvgRow(double max) {
    if (monthlyData.isEmpty) return const SizedBox.shrink();
    final double total = monthlyData.fold<double>(
      0,
      (prev, item) => prev + (double.tryParse(item['usage_m3'].toString()) ?? 0),
    );
    final double avg = total / monthlyData.length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Aylık Ortalama',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
        Text(
          '${avg.toStringAsFixed(1)} m³',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // "Ocak 2024" → "Oca" gibi kısa gösterim
  String _shortMonth(String month) {
    if (month.length >= 3) return month.substring(0, 3);
    return month;
  }
}

class _ChartBar extends StatelessWidget {
  final double value;
  final double maxValue;
  final String month;
  final bool isHighlighted;

  const _ChartBar({
    required this.value,
    required this.maxValue,
    required this.month,
    required this.isHighlighted,
  });

  @override
  Widget build(BuildContext context) {
    final double ratio = maxValue > 0 ? (value / maxValue).clamp(0.05, 1.0) : 0.05;
    const double maxBarHeight = 110;
    final double barHeight = maxBarHeight * ratio;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Değer etiketi (yalnızca vurgulanan)
        if (isHighlighted)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '${value.toStringAsFixed(0)}m³',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.blueBright,
              ),
            ),
          ),
        // Çubuk
        Container(
          width: 32,
          height: barHeight,
          decoration: BoxDecoration(
            gradient: isHighlighted
                ? const LinearGradient(
                    colors: [AppColors.blueMid, AppColors.aqua],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  )
                : null,
            color: isHighlighted ? null : const Color(0xFFDDE6F2),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
        ),
        const SizedBox(height: 6),
        // Ay etiketi
        Text(
          month,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w400,
            color:
                isHighlighted ? AppColors.textPrimary : AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
