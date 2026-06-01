import 'package:flutter/material.dart';

class BillHeroCard extends StatelessWidget {
  final double amount;
  final String dueDate;
  final bool isPaid;
  final List<Map<String, dynamic>>
      taxes; // SQL: bill_taxes tablosundan gelen veriler

  const BillHeroCard({
    Key? key,
    required this.amount,
    required this.dueDate,
    required this.isPaid,
    required this.taxes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade800, Colors.blue.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Güncel Fatura",
                  style: TextStyle(color: Colors.white70, fontSize: 16)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isPaid ? Colors.green : Colors.redAccent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isPaid ? "ÖDENDİ" : "ÖDENMEDİ",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
          const SizedBox(height: 10),
          Text("₺${amount.toStringAsFixed(2)}",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text("Son Ödeme: $dueDate",
              style: const TextStyle(color: Colors.white70)),
          const Divider(color: Colors.white30, height: 30),

          // Vergi Detayları - bill_taxes
          const Text("Vergi ve Kesinti Detayları",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...taxes.map((tax) {
            // Verilerin null veya farklı tipte (int/double) gelme ihtimaline karşı güvenli dönüştürme
            final String name = tax['name']?.toString() ?? 'Bilinmiyor';
            final String rate = (tax['rate'] as num?)?.toString() ?? '0';
            final double taxAmount = (tax['amount'] as num?)?.toDouble() ?? 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("$name (%$rate)",
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12)),
                  Text("₺${taxAmount.toStringAsFixed(2)}",
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
