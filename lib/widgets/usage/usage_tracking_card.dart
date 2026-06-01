import 'package:flutter/material.dart';
import '../../app_colors.dart';
import '../shared/app_card.dart';

/// Güncel ayın kullanım detaylarını gösteren kart.
/// [currentData]: Supabase 'water_usage' tablosundan gelen en son ay verisi.
///
/// Beklenen alanlar:
///   - usage_m3 (num): Ay boyunca kullanılan toplam m³
///   - monthly_limit_m3 (num, opsiyonel): Belirlenen aylık hedef (yoksa 30 varsayılır)
///   - daily_avg_m3 (num, opsiyonel): Günlük ortalama kullanım
///   - month_name (String): Ayın adı
class UsageTrackingCard extends StatelessWidget {
  final Map<String, dynamic>? currentData;

  const UsageTrackingCard({super.key, this.currentData});

  @override
  Widget build(BuildContext context) {
    if (currentData == null) {
      return AppCard(
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Text(
              'Kullanım verisi bulunamadı.',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
        ),
      );
    }

    final double usage = (currentData!['usage_m3'] as num?)?.toDouble() ?? 0;
    final double current = (currentData!['current_m3'] as num?)?.toDouble() ?? 0;
    final String monthName = currentData!['month_name'] ?? 'Bu Ay';

    // Hedef yokse kullanım değerine göre dinamik hesapla
    final double limit = current > 0 ? current * 1.2 : usage * 1.3;
    final double dailyAvg = usage / 30;

    final double progress = limit > 0 ? (usage / limit).clamp(0.0, 1.0) : 0;
    final double remaining = (limit - usage).clamp(0, double.infinity);
    final bool isOverLimit = usage > limit;

    Color progressColor = AppColors.greenSave;
    if (progress > 0.85) {
      progressColor = AppColors.redAlert;
    } else if (progress > 0.65) progressColor = AppColors.yellowWarn;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kullanım Takibi',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    monthName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              // Kullanım yüzdesi daire göstergesi
              _CircularIndicator(progress: progress, color: progressColor),
            ],
          ),
          const SizedBox(height: 20),
          // Kullanım ve hedef değerleri
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${usage.toStringAsFixed(1)} m³',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                '/ ${limit.toStringAsFixed(0)} m³ hedef',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // İlerleme çubuğu
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.softBg,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          const SizedBox(height: 8),
          // Alt bilgi satırı
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isOverLimit
                    ? '⚠️ Limit aşıldı!'
                    : '${remaining.toStringAsFixed(1)} m³ kaldı',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isOverLimit ? AppColors.redAlert : AppColors.textMuted,
                ),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: progressColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 14),
          // Günlük ortalama
          Row(
            children: [
              _SmallStat(
                icon: '📅',
                label: 'Günlük Ort.',
                value: '${dailyAvg.toStringAsFixed(2)} m³',
              ),
              const SizedBox(width: 24),
              _SmallStat(
                icon: '🎯',
                label: 'Günlük Hedef',
                value: '${(limit / 30).toStringAsFixed(2)} m³',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircularIndicator extends StatelessWidget {
  final double progress;
  final Color color;

  const _CircularIndicator({required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 54,
      height: 54,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 6,
            backgroundColor: AppColors.softBg,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          Text(
            '${(progress * 100).toInt()}%',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallStat extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _SmallStat(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style:
                    const TextStyle(fontSize: 10, color: AppColors.textMuted)),
            Text(value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                )),
          ],
        ),
      ],
    );
  }
}
