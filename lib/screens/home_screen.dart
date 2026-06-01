import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../services/session_service.dart';
import '../services/supabase_service.dart';
import '../widgets/home/bill_hero_card.dart';
import '../widgets/home/leak_alert_banner.dart';
import '../widgets/home/fault_tracker_card.dart';
import '../widgets/home/safe_payment_card.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _fullName = 'Yükleniyor...';
  String _initials = '';
  bool _isLoading = true;

  // Supabase'den gelecek dinamik veriler için değişkenler
  Map<String, dynamic>? _currentBill;
  List<Map<String, dynamic>> _leakAlerts = [];
  List<Map<String, dynamic>> _faults = [];

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    // SessionService'den kullanıcı ID'sini alıyoruz
    final userId = SessionService.userId;
    if (userId == null) {
      _setFallbackUser();
      return;
    }

    try {
      // Tüm verileri SupabaseService üzerinden eşzamanlı veya sırayla çekiyoruz
      final profile = await SupabaseService().getProfile(userId.toString());
      final bill = await SupabaseService().getCurrentBill(userId.toString());
      final alerts = await SupabaseService().getLeakAlerts();
      final faults = await SupabaseService().getFaults(userId.toString());

      if (mounted) {
        setState(() {
          _fullName = profile?['full_name'] ?? 'Kullanıcı';
          _initials = _getInitials(_fullName);
          _currentBill = bill;
          _leakAlerts = alerts;
          _faults = faults;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Home data error: $e');
      if (mounted) _setFallbackUser();
    }
  }

  void _setFallbackUser() {
    setState(() {
      _fullName = 'Misafir Kullanıcı';
      _initials = 'MK';
      _isLoading = false;
    });
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '??';
    List<String> nameParts = name.trim().split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBg,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),

          // 1. GÜNCEL FATURA KARTI (Eğer veritabanından fatura geldiyse gösterilir)
          if (_currentBill != null)
            SliverToBoxAdapter(
              child: BillHeroCard(
                amount: (_currentBill!['amount'] ?? 0).toDouble(),
                dueDate: _currentBill!['due_date'] ?? 'Tarih Yok',
                isPaid: _currentBill!['is_paid'] ?? false,
                taxes: _currentBill!['bill_taxes'] != null
                    ? List<Map<String, dynamic>>.from(
                        _currentBill!['bill_taxes'])
                    : const [], // Eğer vergi datası yoksa boş liste gönder
              ),
            ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 2. SIZINTI UYARILARI (Eğer uyarı listesi boş değilse göster)
                if (_leakAlerts.isNotEmpty) ...[
                  const LeakAlertBanner(), // İleride bu widget'ı dinamik veriye bağlayabilirsiniz
                  const SizedBox(height: 14),
                ],

                // 3. ARIZA VE İHBAR TAKİBİ (Eğer kullanıcının arızası varsa ilkini göster)
                if (_faults.isNotEmpty) ...[
                  FaultTrackerCard(
                    title: _faults.first['title'] ?? 'Boru Patlağı İhbarı',
                    location: _faults.first['location'] ?? 'Bilinmiyor',
                    status: _faults.first['status'] ?? 'pending',
                    faultType: _faults.first['fault_type'] ?? 'general',
                  ),
                  const SizedBox(height: 14),
                ],

                // Sabit kalan güvenli ödeme kartı
                const SafePaymentCard(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.blueDeep, AppColors.blueMid, AppColors.blueBright],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.6, 1.0],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned(
                top: -60,
                right: -60,
                child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.aqua.withValues(alpha: 0.12)))),
            Positioned(
                bottom: -30,
                left: 40,
                child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.07)))),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white.withValues(alpha: 0.18)),
                            child: const Center(
                                child:
                                    Text('💧', style: TextStyle(fontSize: 18))),
                          ),
                          const SizedBox(width: 8),
                          const Text('AquaPanel',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3)),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ProfileScreen())),
                        child: Stack(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                    colors: [
                                      AppColors.aqua,
                                      AppColors.blueBright
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight),
                                border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    width: 2),
                              ),
                              child: Center(
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 12,
                                          height: 12,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: AppColors.blueDeep))
                                      : Text(_initials,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.blueDeep))),
                            ),
                            Positioned(
                                top: 1,
                                right: 1,
                                child: Container(
                                    width: 9,
                                    height: 9,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.redAlert,
                                        border: Border.all(
                                            color: Colors.white, width: 1.5)))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('Hoş geldin,',
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.7))),
                  const SizedBox(height: 4),
                  Text('$_fullName 👋',
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.3)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
