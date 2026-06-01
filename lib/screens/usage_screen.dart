import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../app_colors.dart';
import '../widgets/shared/gradient_header.dart';
import '../widgets/usage/monthly_chart_card.dart';
import '../widgets/usage/usage_tracking_card.dart';
import '../widgets/usage/usage_breakdown_card.dart';

class UsageScreen extends StatefulWidget {
  const UsageScreen({super.key});

  @override
  State<UsageScreen> createState() => _UsageScreenState();
}

class _UsageScreenState extends State<UsageScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  // Supabase'den gelecek verileri tutacağımız listeler ve değişkenler
  List<Map<String, dynamic>> _monthlyUsageData = [];
  Map<String, dynamic>? _currentMonthData;

  @override
  void initState() {
    super.initState();
    _fetchUsageData();
  }

  Future<void> _fetchUsageData() async {
    try {
      final response = await Supabase.instance.client
          .from('water_usage')
          .select()
          .order('month_number', ascending: false)
          .limit(6); // Son 6 ayın verisini grafikte göstermek için alıyoruz

      if (response.isNotEmpty) {
        // En güncel ayın verisini ayrı bir değişkene alıyoruz (UsageTrackingCard için)
        final current = response.first;

        // Grafikte eski aydan yeni aya doğru (soldan sağa) göstermek için listeyi tersine çeviriyoruz
        final reversedList = List<Map<String, dynamic>>.from(response.reversed);

        setState(() {
          _monthlyUsageData = reversedList;
          _currentMonthData = current;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Kullanım verileri çekilirken hata: $e');
      setState(() {
        _errorMessage = 'Veriler yüklenirken hata: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBg,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
              child: GradientHeader(
                  emoji: '📈',
                  title: 'Kullanım',
                  subtitle: 'Su tüketim takibi')),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            sliver: _isLoading
                ? const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _errorMessage != null
                    ? SliverFillRemaining(
                        child: Center(
                            child: Text(_errorMessage!,
                                style: const TextStyle(
                                    color: AppColors.redAlert))),
                      )
                    : SliverList(
                        delegate: SliverChildListDelegate([
                          // 1. Grafik Kartı: Son 6 ayın verisini liste olarak gönderiyoruz
                          MonthlyChartCard(monthlyData: _monthlyUsageData),
                          const SizedBox(height: 14),

                          // 2. Takip Kartı: Sadece içinde bulunduğumuz ayın detaylarını gönderiyoruz
                          UsageTrackingCard(currentData: _currentMonthData),
                          const SizedBox(height: 14),

                          // 3. Dağılım Kartı: Yine güncel ayın oda bazlı dağılımını gönderiyoruz
                          UsageBreakdownCard(currentData: _currentMonthData),

                          if (_monthlyUsageData.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Center(
                                  child: Text(
                                      'Henüz kullanım verisi bulunmuyor.',
                                      style: TextStyle(
                                          color: AppColors.textMuted))),
                            )
                        ]),
                      ),
          ),
        ],
      ),
    );
  }
}
