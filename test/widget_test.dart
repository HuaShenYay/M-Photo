import 'package:flutter_test/flutter_test.dart';
import 'package:watermark_frame_tool/main.dart';

void main() {
  testWidgets('App launches correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const WatermarkApp());

    // Verify that the app title is displayed
    expect(find.text('M的相框'), findsOneWidget);
  });
}
