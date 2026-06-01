import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../app_colors.dart';
import '../widgets/shared/gradient_header.dart';
import '../widgets/news/quick_actions_card.dart';
import '../widgets/news/outage_card.dart';
import '../widgets/news/tip_card.dart';
import '../widgets/news/news_card.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  List<Map<String, dynamic>> _outages = [];
  List<Map<String, dynamic>> _tips = [];
  List<Map<String, dynamic>> _news = [];

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  Future<void> _fetchNews() async {
    try {
      final response = await Supabase.instance.client
          .from('announcements')
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false);

      List<Map<String, dynamic>> tempOutages = [];
      List<Map<String, dynamic>> tempTips = [];
      List<Map<String, dynamic>> tempNews = [];

      for (var item in response) {
        final type = item['type'] as String?;
        if (type == 'outage') {
          tempOutages.add(item);
        } else if (type == 'tip') {
          tempTips.add(item);
        } else if (type == 'news') {
          tempNews.add(item);
        }
      }

      setState(() {
        _outages = tempOutages;
        _tips = tempTips;
        _news = tempNews;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Haberler yüklenirken hata oluştu: $e';
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
                  emoji: '📰',
                  title: 'Haberler',
                  subtitle: 'Duyurular & kesintiler')),
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
                                style: const TextStyle(color: Colors.red))),
                      )
                    : SliverList(
                        delegate: SliverChildListDelegate([
                          const QuickActionsCard(),
                          const SizedBox(height: 14),
                          if (_outages.isNotEmpty) ...[
                            ..._outages.map((outage) => Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  // HATA DÜZELTİLDİ: OutageCard'ın güncel yapısına göre parametreler atandı
                                  child: OutageCard(
                                    title:
                                        outage['title'] ?? 'Kesinti Bildirimi',
                                    description: outage['description'] ?? '',
                                    affectedAreas: outage['affected_areas'] ??
                                        'Belirtilmedi',
                                    startTime:
                                        outage['start_time'] ?? 'Belirtilmedi',
                                    durationHours: outage['duration_hours'] !=
                                            null
                                        ? num.tryParse(
                                            outage['duration_hours'].toString())
                                        : null,
                                    alternativeSolutions:
                                        outage['alternative_solutions'],
                                  ),
                                )),
                          ],
                          if (_tips.isNotEmpty) ...[
                            ..._tips.map((tip) => Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: TipCard(data: tip),
                                )),
                          ],
                          if (_news.isNotEmpty) ...[
                            ..._news.map((newsItem) => Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: NewsCard(data: newsItem),
                                )),
                          ],
                          if (_outages.isEmpty &&
                              _tips.isEmpty &&
                              _news.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Center(
                                child: Text(
                                    'Şu an için yeni bir duyuru bulunmuyor.',
                                    style:
                                        TextStyle(color: AppColors.textMuted)),
                              ),
                            )
                        ]),
                      ),
          ),
        ],
      ),
    );
  }
}
