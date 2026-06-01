import 'package:flutter/material.dart';
import '../services/session_service.dart';
import '../services/supabase_service.dart';
import '../widgets/home/bill_hero_card.dart';

class BillsScreen extends StatefulWidget {
  const BillsScreen({Key? key}) : super(key: key);

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  List<Map<String, dynamic>> _bills = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBills();
  }

  Future<void> _fetchBills() async {
    final userId = SessionService.userId;
    if (userId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      // SupabaseService üzerinden kullanıcının faturalarını çekiyoruz
      final data = await SupabaseService().getBills(userId.toString());

      if (mounted) {
        setState(() {
          _bills = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Faturalar yüklenirken hata: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_bills.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Faturalar ve Şeffaflık")),
        body: const Center(child: Text("Henüz hiç faturanız bulunmuyor.")),
      );
    }

    // En güncel faturayı al (Listenin ilk elemanı, çünkü getBills genellikle desc sıralı döner)
    final currentBill = _bills.first;
    final currentBillAmount =
        (currentBill['amount'] as num?)?.toDouble() ?? 0.0;

    // Varsa bir önceki faturayı al, yoksa güncel tutarla aynı say (Zam oranı %0 çıkar)
    double previousBillAmount = currentBillAmount;
    if (_bills.length > 1) {
      previousBillAmount =
          (_bills[1]['amount'] as num?)?.toDouble() ?? currentBillAmount;
    }

    // Zam/Artış oranı hesaplama
    double increaseRate = 0.0;
    if (previousBillAmount > 0) {
      increaseRate =
          ((currentBillAmount - previousBillAmount) / previousBillAmount) * 100;
    }

    // SQL: bill_taxes verisi (Eğer mevcut faturaya join yapılmışsa)
    final List<Map<String, dynamic>> billTaxes =
        currentBill['bill_taxes'] != null
            ? List<Map<String, dynamic>>.from(currentBill['bill_taxes'])
            : [];

    return Scaffold(
      appBar: AppBar(title: const Text("Faturalar ve Şeffaflık")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BillHeroCard(
              amount: currentBillAmount,
              dueDate: currentBill['due_date']?.toString() ?? 'Tarih Yok',
              isPaid: currentBill['is_paid'] ?? false,
              taxes: billTaxes,
            ),
            const SizedBox(height: 24),

            // Zam / Artış Oranı Kartı (Sadece 2 veya daha fazla fatura varsa anlamlıdır)
            if (_bills.length > 1) ...[
              _buildRateCard(increaseRate),
              const SizedBox(height: 24),
            ],

            // Hesap Verebilirlik & Vergi Dağılımı (Accountability)
            if (billTaxes.isNotEmpty) ...[
              const Text("Hesap Verebilirlik ve Şeffaflık",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildAccountabilitySection(billTaxes),
            ] else ...[
              const Center(
                  child: Text("Bu faturaya ait vergi detayı bulunamadı.")),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildRateCard(double increaseRate) {
    final isIncrease = increaseRate > 0;
    return Card(
      color: isIncrease ? Colors.red.shade50 : Colors.green.shade50,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
            color: isIncrease ? Colors.red.shade200 : Colors.green.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              isIncrease ? Icons.trending_up : Icons.trending_down,
              color: isIncrease ? Colors.red : Colors.green,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Geçen Aya Göre Değişim Oranı",
                    style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "%${increaseRate.abs().toStringAsFixed(1)} ${isIncrease ? 'Artış' : 'Düşüş'}",
                    style: TextStyle(
                      color: isIncrease ? Colors.red : Colors.green,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isIncrease)
                    const Text(
                      "Su tüketiminiz veya güncel tarifelerdeki zam oranları faturanıza yansımıştır.",
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAccountabilitySection(List<Map<String, dynamic>> taxes) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Ödediğiniz Vergiler Nereye Gidiyor?",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            ...taxes
                .map((tax) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.account_balance,
                              size: 20, color: Colors.blue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${tax['name'] ?? 'Vergi'} Kategorisi",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Text(
                                  _getTaxExplanation(
                                      tax['name']?.toString() ?? ''),
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ))
                .toList()
          ],
        ),
      ),
    );
  }

  // Vergi tipine göre şeffaflık açıklaması döndüren yardımcı fonksiyon
  String _getTaxExplanation(String taxName) {
    final nameUpper = taxName.toUpperCase();
    if (nameUpper.contains('ÇTV')) {
      return "Çevre Temizlik Vergisi, belediyenizin atık yönetimi ve sokak temizliği hizmetlerini finanse eder.";
    } else if (nameUpper.contains('KDV')) {
      return "Katma Değer Vergisi, altyapı projeleri için doğrudan devlet hazinesine aktarılır.";
    } else if (nameUpper.contains('ATIK')) {
      return "Kullandığınız suyun arıtma tesislerinde temizlenerek doğaya geri kazandırılması için harcanır.";
    } else {
      return "İlgili yasal mevzuatlar gereği tahsil edilen resmi vergi bedelidir.";
    }
  }
}
