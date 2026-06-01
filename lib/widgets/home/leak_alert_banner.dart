import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../app_colors.dart';

/// Supabase 'alerts' tablosundan type='leak' olan aktif alarmları çeker.
/// Alarm yoksa görünmez olur.
class LeakAlertBanner extends StatefulWidget {
  const LeakAlertBanner({super.key});

  @override
  State<LeakAlertBanner> createState() => _LeakAlertBannerState();
}

class _LeakAlertBannerState extends State<LeakAlertBanner> {
  List<Map<String, dynamic>> _alerts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLeakAlerts();
  }

  Future<void> _fetchLeakAlerts() async {
    try {
      final response = await Supabase.instance.client
          .from('alerts')
          .select()
          .eq('type', 'leak')
          .eq('is_active', true)
          .order('created_at', ascending: false);

      setState(() {
        _alerts = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Sızıntı alarmları çekilirken hata: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Yükleniyor veya alarm yoksa hiç render etme
    if (_isLoading || _alerts.isEmpty) return const SizedBox.shrink();

    return Column(
      children: _alerts.map((alert) => _LeakAlertCard(alert: alert)).toList(),
    );
  }
}

class _LeakAlertCard extends StatelessWidget {
  final Map<String, dynamic> alert;
  const _LeakAlertCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    final String title = alert['title'] ?? 'Olası Sızıntı Tespit Edildi';
    final String description =
        alert['description'] ?? 'Lütfen su tesisatınızı kontrol edin.';
    final String location = alert['location'] ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFF6E8),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFFFD580), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.yellowWarn.withValues(alpha: 0.12),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEDC0),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Text('⚠️', style: TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF92400E),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFB45309),
                    ),
                  ),
                  if (location.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded,
                            size: 12, color: AppColors.yellowWarn),
                        const SizedBox(width: 3),
                        Text(
                          location,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.yellowWarn,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
