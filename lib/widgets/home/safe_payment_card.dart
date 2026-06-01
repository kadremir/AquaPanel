import 'package:flutter/material.dart';
import '../../app_colors.dart';
import '../shared/app_card.dart';

/// Statik güvenli ödeme bilgi kartı.
/// Güvenlik ikonları ve kısa açıklama içerir.
class SafePaymentCard extends StatelessWidget {
  const SafePaymentCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.blueMid, AppColors.blueBright],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('🔒', style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Güvenli Ödeme',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '256-bit SSL şifrelemeli',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 14),
          // Özellik listesi
          _FeatureRow(
            icon: '🛡️',
            title: '3D Secure Doğrulama',
            subtitle: 'Tüm ödemeler doğrulanır',
          ),
          const SizedBox(height: 10),
          _FeatureRow(
            icon: '🏦',
            title: 'Tüm Bankalar Kabul Edilir',
            subtitle: 'Kredi & banka kartı desteği',
          ),
          const SizedBox(height: 10),
          _FeatureRow(
            icon: '🔄',
            title: 'Otomatik Ödeme',
            subtitle: 'Her ay zamanında ödensin',
          ),
          const SizedBox(height: 16),
          // CTA butonu
          GestureDetector(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Ödeme sayfasına yönlendiriliyorsunuz…')),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.blueMid, AppColors.blueBright],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '💳  Ödeme Yap',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.softBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(child: Text(icon, style: const TextStyle(fontSize: 16))),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
        const Spacer(),
        const Icon(Icons.check_circle_rounded,
            color: AppColors.greenSave, size: 18),
      ],
    );
  }
}
