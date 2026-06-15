/// # Swish-banner
///
/// En grön banner som visas längst ner i varje artikel och på Stöd-skärmen.
/// Innehåller Swish-numret och en knapp för att kopiera det.
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
      padding: EdgeInsets.all(compact ? 12 : 20),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.volunteer_activism, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'Stöd Dumpens arbete',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Swisha till:',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: compact ? 14 : 16,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                swishNumber,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: compact ? 22 : 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              IconButton(
                onPressed: () async {
                  await Clipboard.setData(
                    const ClipboardData(text: swishNumber),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Swish-numret kopierat'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.copy, color: Colors.white),
                tooltip: 'Kopiera Swish-nummer',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
