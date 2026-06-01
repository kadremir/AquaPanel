import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../app_colors.dart';
import '../widgets/shared/app_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _profileData = {};
  String _initials = '';

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user != null) {
        // Oturum açmış kullanıcının verilerini 'profiles' tablosundan çekiyoruz
        final response = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('user_id', user.id)
            .maybeSingle();

        if (response != null) {
          setState(() {
            _profileData = response;
            _initials = _getInitials(response['full_name'] ?? '');
            _isLoading = false;
          });
          return;
        }
      }

      // Eğer kullanıcı oturumu yoksa veya veri bulunamazsa varsayılan (fallback) verileri kullan
      _setFallbackData();
    } catch (e) {
      debugPrint('Profil verileri yüklenirken hata: $e');
      _setFallbackData();
    }
  }

  void _setFallbackData() {
    setState(() {
      _profileData = {
        'full_name': 'Misafir Kullanıcı',
        'email': 'misafir@aquapanel.com',
        'subscriber_no': '0000-0000-0000',
        'address': 'Adres bilgisi bulunamadı',
        'district': 'Bilinmiyor',
        'phone': '-',
        'meter_no': '-',
        'subscription_date': '-',
        'status': 'Pasif'
      };
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

  Future<void> _handleLogout(BuildContext context) async {
    try {
      // Supabase oturumunu kapat
      await Supabase.instance.client.auth.signOut();

      if (context.mounted) {
        // Çıkış yaptıktan sonra login/ana sayfaya yönlendirme yapabilirsiniz
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Başarıyla çıkış yapıldı.')));

        // Örnek: Login sayfasına dön ve geçmişi sil
        // Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Çıkış yapılamadı: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBg,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            sliver: _isLoading
                ? const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()))
                : SliverList(
                    delegate: SliverChildListDelegate([
                    _buildInfoCard(),
                    const SizedBox(height: 14),
                    _buildSubscriptionCard(),
                    const SizedBox(height: 14),
                    _buildMenuCard(context),
                    const SizedBox(height: 14),
                    _buildLogoutBtn(context),
                  ])),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final fullName = _profileData['full_name'] ?? 'Bilinmiyor';
    final email = _profileData['email'] ?? 'E-posta yok';
    final subscriberNo = _profileData['subscriber_no'] ?? 'Bilinmiyor';

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [
          AppColors.blueDeep,
          AppColors.blueMid,
          AppColors.blueBright
        ], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned(
                top: -40,
                right: -40,
                child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.aqua.withValues(alpha: 0.12)))),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white.withValues(alpha: 0.18)),
                          child: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.white, size: 16),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text('Profil',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                          colors: [AppColors.aqua, AppColors.blueBright],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4), width: 3),
                    ),
                    child: Center(
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: AppColors.blueDeep)
                            : Text(_initials,
                                style: const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.blueDeep))),
                  ),
                  const SizedBox(height: 12),
                  Text(fullName,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(email,
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.7))),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20)),
                    child: Text('Abone No: $subscriberNo',
                        style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Adres Bilgileri',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 14),
          _InfoRow(
              icon: '🏠',
              label: 'Adres',
              value: _profileData['address'] ?? '-'),
          const Divider(color: AppColors.border, height: 20),
          _InfoRow(
              icon: '📍',
              label: 'İlçe',
              value: _profileData['district'] ?? '-'),
          const Divider(color: AppColors.border, height: 20),
          _InfoRow(
              icon: '📱',
              label: 'Telefon',
              value: _profileData['phone'] ?? '-'),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard() {
    final status = _profileData['status'] ?? 'Bilinmiyor';
    final isAktif = status.toString().toLowerCase() == 'aktif';

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Abonelik Bilgileri',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 14),
          _InfoRow(
              icon: '💧',
              label: 'Sayaç No',
              value: _profileData['meter_no'] ?? '-'),
          const Divider(color: AppColors.border, height: 20),
          _InfoRow(
              icon: '📅',
              label: 'Abonelik Tarihi',
              value: _profileData['subscription_date'] ?? '-'),
          const Divider(color: AppColors.border, height: 20),
          _InfoRow(
              icon: isAktif ? '✅' : '⏸️',
              label: 'Durum',
              value: status,
              valueColor: isAktif ? AppColors.greenSave : AppColors.yellowWarn),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context) {
    const items = [
      {'icon': '🔔', 'label': 'Bildirim Ayarları'},
      {'icon': '🔒', 'label': 'Güvenlik'},
      {'icon': '📄', 'label': 'Kullanım Koşulları'},
      {'icon': '💬', 'label': 'Destek & Yardım'},
      {'icon': '⭐', 'label': 'Uygulamayı Değerlendir'},
    ];
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: List.generate(
            items.length,
            (i) => Column(
                  children: [
                    GestureDetector(
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('${items[i]['label']} açılıyor…'),
                              duration: const Duration(seconds: 1))),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 14),
                        color: Colors.transparent,
                        child: Row(
                          children: [
                            Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                    color: AppColors.softBg,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Center(
                                    child: Text(items[i]['icon']!,
                                        style: const TextStyle(fontSize: 17)))),
                            const SizedBox(width: 14),
                            Expanded(
                                child: Text(items[i]['label']!,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textPrimary))),
                            const Icon(Icons.chevron_right_rounded,
                                color: AppColors.textMuted, size: 20),
                          ],
                        ),
                      ),
                    ),
                    if (i < items.length - 1)
                      const Divider(
                          color: AppColors.border,
                          height: 1,
                          indent: 18,
                          endIndent: 18),
                  ],
                )),
      ),
    );
  }

  Widget _buildLogoutBtn(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          _handleLogout(context), // Gerçek logout fonksiyonuna bağlandı
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
            color: const Color(0xFFFFF0F0),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFFCCCC), width: 1.5)),
        child: const Text('🚪  Çıkış Yap',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.redAlert)),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String icon, label, value;
  final Color? valueColor;
  const _InfoRow(
      {required this.icon,
      required this.label,
      required this.value,
      this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        Text(label,
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
        const Spacer(),
        Expanded(
          flex: 2,
          child: Text(value,
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppColors.textPrimary)),
        ),
      ],
    );
  }
}
