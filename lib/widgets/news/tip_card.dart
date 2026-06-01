import 'package:flutter/material.dart';
import '../../app_colors.dart';

/// Supabase 'announcements' tablosundan type='tip' olan kayıtlar için kart.
/// [data]: İlgili duyuru satırı.
///
/// Beklenen alanlar:
///   - title (String)
///   - description (String, opsiyonel)
///   - saving_liters (num, opsiyonel): Bu ipucu ile tasarruf edilebilecek litre
///   - created_at (String): ISO tarih
class TipCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const TipCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final String title = data['title'] ?? 'Su Tasarrufu İpucu';
    final String description = data['description'] ?? '';
    final num? saving = data['saving_liters'];
    final String createdAt = data['created_at'] != null
        ? _formatDate(data['created_at'])
        : '';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE8F9F0),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFBBF0D6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.greenSave.withValues(alpha: 0.10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Center(
              child: Text('💡', style: TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TASARRUF İPUCU',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.greenSave,
                        letterSpacing: 0.8,
                      ),
                    ),
                    if (createdAt.isNotEmpty)
                      Text(createdAt,
                          style: const TextStyle(
                              fontSize: 10, color: AppColors.textMuted)),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF065F46),
                  ),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF047857),
                      height: 1.4,
                    ),
                  ),
                ],
                if (saving != null && saving > 0) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.greenSave,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '💧 ${saving}L/gün tasarruf',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String rawDate) {
    try {
      final dt = DateTime.parse(rawDate).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}';
    } catch (_) {
      return rawDate;
    }
  }
}
