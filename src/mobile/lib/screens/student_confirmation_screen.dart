import 'package:flutter/material.dart';

import '../widgets/animated_background.dart';
import '../utils/app_localizations.dart';

class StudentConfirmationScreen extends StatefulWidget {
  const StudentConfirmationScreen({Key? key}) : super(key: key);

  @override
  State<StudentConfirmationScreen> createState() => _StudentConfirmationScreenState();
}

class _StudentConfirmationScreenState extends State<StudentConfirmationScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text(
          AppLocalizations.of(context).t('student_confirmation_title'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.description_outlined),
            onPressed: () {
              // Placeholder action for the right-side icon (matches ServicesScreen tile)
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Use the shared AnimatedBackground widget for the animated backdrop
          Positioned.fill(
            child: AnimatedBackground(isDark: isDark),
          ),

          // Safe area for content; leave content area empty as requested
          SafeArea(
            child: Column(
              children: [
                // Keep space under the header; rest intentionally left empty
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    // Intentionally empty: UI under header to be implemented later
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
