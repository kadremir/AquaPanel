import 'package:flutter_test/flutter_test.dart';
import 'package:aquapanel/main.dart';

void main() {
  testWidgets('smoke test', (tester) async {
    await tester.pumpWidget(const AquaPanelApp());
  });
}
