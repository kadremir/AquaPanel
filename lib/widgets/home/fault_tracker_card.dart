import 'package:flutter/material.dart';

class FaultTrackerCard extends StatelessWidget {
  final String title;
  final String location;
  final String status;
  final String faultType; // SQL: fault_type ('individual', 'general')

  const FaultTrackerCard({
    Key? key,
    required this.title,
    required this.location,
    required this.status,
    required this.faultType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isGeneral = faultType == 'general';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: isGeneral
              ? Colors.red.withOpacity(0.1)
              : Colors.orange.withOpacity(0.1),
          child: Icon(
            isGeneral ? Icons.public : Icons.person,
            color: isGeneral ? Colors.red : Colors.orange,
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(title,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isGeneral ? Colors.red : Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isGeneral ? 'Genel Arıza' : 'Şahıs Arızası',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text("Konum: $location"),
            const SizedBox(height: 4),
            Text("Durum: ${status.toUpperCase()}",
                style: const TextStyle(color: Colors.blueGrey)),
          ],
        ),
      ),
    );
  }
}
