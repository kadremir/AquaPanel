import 'package:flutter/material.dart';
import '../../app_colors.dart';

/// Supabase 'announcements' tablosundan type='news' olan kayıtlar için kart.
/// [data]: İlgili duyuru satırı.
///
/// Beklenen alanlar:
///   - title (String)
///   - description (String, opsiyonel)
///   - image_url (String, opsiyonel): Haber görseli
///   - source (String, opsiyonel): Haber kaynağı
///   - created_at (String): ISO tarih
class NewsCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const NewsCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final String title = data['title'] ?? 'Duyuru';
    final String description = data['description'] ?? '';
    final String? imageUrl = data['image_url'];
    final String source = data['source'] ?? 'AquaPanel';
    final String createdAt = data['created_at'] != null
        ? _formatDate(data['created_at'])
        : '';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A2463).withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Görsel (varsa)
            if (imageUrl != null && imageUrl.isNotEmpty)
              Image.network(
                imageUrl,
                width: double.infinity,
                height: 160,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 80,
                  color: AppColors.softBg,
                  child: const Center(
                    child: Text('🗞️', style: TextStyle(fontSize: 32)),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Üst meta satırı
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEBF5FF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          source,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.blueMid,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (createdAt.isNotEmpty)
                        Text(
                          createdAt,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textMuted),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Başlık
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                        height: 1.45,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  // Devamını oku
                  GestureDetector(
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$title detayları açılıyor…'),
                        duration: const Duration(seconds: 1),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'Devamını Oku',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.blueBright,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded,
                            size: 14, color: AppColors.blueBright),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String rawDate) {
    try {
      final dt = DateTime.parse(rawDate).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
    } catch (_) {
      return rawDate;
    }
  }
}
