/// # Gädd-header
///
/// Header med gädd-bild som matchar dumpen.se's varumärke.
/// Innehåller app-titel och sökknapp.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

class PikeHeader extends StatelessWidget {
  final VoidCallback? onSearch;

  const PikeHeader({super.key, this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF1a2332),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SizedBox(
              height: 140,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Gädd-bild bakgrund
                  Image.asset(
                    'assets/gaddan.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFF1a2332),
                    ),
                  ),
                  // Mörk overlay så text syns bra
                  Container(
                    color: Colors.black.withValues(alpha: 0.25),
                  ),
                  // Innehåll ovanpå
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        // D-dumpen monogram
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.accentYellow,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              'D',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'DUMPEN',
                          style: GoogleFonts.jost(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3,
                            fontSize: 18,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.search, color: Colors.white),
                          tooltip: 'Sök',
                          onPressed: onSearch,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Gul accent-linje
            Container(
              height: 3,
              width: double.infinity,
              color: AppColors.accentYellow,
            ),
          ],
        ),
      ),
    );
  }
}
