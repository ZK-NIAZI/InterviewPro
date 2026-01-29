// This is a basic Flutter widget test for InterviewPro app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:interview_pro_app/main.dart';

void main() {
  testWidgets('InterviewPro app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const InterviewProApp());

    // Verify that splash screen shows InterviewPro text
    expect(find.text('InterviewPro'), findsOneWidget);

    // Verify that the mic icon is present
    expect(find.byIcon(Icons.mic), findsOneWidget);
  });
}
