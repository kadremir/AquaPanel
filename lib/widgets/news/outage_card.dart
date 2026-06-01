import 'package:flutter/material.dart';
import '../../app_colors.dart';

class OutageCard extends StatelessWidget {
  final String title;
  final String description;
  final String affectedAreas;
  final num? durationHours; // SQL: duration_hours
  final String? alternativeSolutions; // SQL: alternative_solutions
  final String startTime;

  const OutageCard({
    Key? key,
    required this.title,
    required this.description,
    required this.affectedAreas,
    this.durationHours,
    this.alternativeSolutions,
    required this.startTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: Colors.orange, size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(description),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                    child: Text("Etkilenen Bölgeler: $affectedAreas",
                        style: const TextStyle(color: Colors.grey))),
              ],
            ),
            const SizedBox(height: 8),
            if (durationHours != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer, size: 16, color: Colors.red),
                    const SizedBox(width: 4),
                    Text(
                      "Tahmini Kesinti Süresi: $durationHours saat",
                      style: const TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            if (alternativeSolutions != null &&
                alternativeSolutions!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.lightbulb_outline,
                            size: 18, color: Colors.blue),
                        SizedBox(width: 6),
                        Text("Alternatif Çözüm",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(alternativeSolutions!),
                  ],
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}
