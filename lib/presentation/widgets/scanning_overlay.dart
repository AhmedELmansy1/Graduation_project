import 'package:flutter/material.dart';

class ScanningOverlay extends StatelessWidget {
  final String message;
  const ScanningOverlay({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.85),
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Safe, Static Scanner
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.2), width: 2),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              message.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "SECURE FORENSIC PIPELINE ACTIVE",
              style: TextStyle(color: Colors.white24, fontSize: 8, letterSpacing: 2),
            ),
          ],
        ),
      ),
    );
  }
}
