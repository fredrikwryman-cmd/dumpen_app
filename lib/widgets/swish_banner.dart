/// # Swish-banner
///
/// Gul banner (matchar Dumpens accentfärg) med Swish-nummer och kopiera-knapp.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

class SwishBanner extends StatelessWidget {
  final bool compact;

  const SwishBanner({super.key, this.compact = false});

  static const String swishNumber = AppConstants.swishNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: EdgeInsets.all(compact ? 14 : 20),
      decoration: BoxDecoration(
        color: AppColors.accentYellow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.volunteer_activism, color: Colors.black, size: compact ? 20 : 24),
              const SizedBox(width: 8),
              Text(
                'Stöd Dumpens arbete',
                style: TextStyle(
                  fontFamily: 'sans-serif',
                  color: Colors.black,
                  fontSize: compact ? 16 : 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Swisha till:',
                    style: TextStyle(
                      fontFamily: 'sans-serif',
                      color: Colors.black.withValues(alpha: 0.6),
                      fontSize: compact ? 13 : 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    swishNumber,
                    style: TextStyle(
                      fontFamily: 'sans-serif',
                      color: Colors.black,
                      fontSize: compact ? 22 : 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () async {
                  await Clipboard.setData(
                    const ClipboardData(text: swishNumber),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Swish-numret kopierat',
                          style: TextStyle(fontFamily: 'sans-serif'),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.copy, color: Colors.black),
                tooltip: 'Kopiera Swish-nummer',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
