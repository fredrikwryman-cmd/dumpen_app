/// # Stöd-skärm
///
/// Visar Swish-nummer, QR-kod för betalning, fakta om Dumpen och knappar
/// för att kopiera nummer, öppna Swish, dela appen och besöka hemsidan.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../widgets/swish_banner.dart';

class DonateScreen extends StatelessWidget {
  const DonateScreen({super.key});

  static const String _swishNumber = SwishBanner.swishNumber;
  static const String _swishUrl = AppConstants.swishUrl;
  static const String _websiteUrl = AppConstants.dumpenWebsite;
  static const String _appShareText =
      'Ladda ner Dumpen-appen och stöd barnrättsrörelsen: ${AppConstants.dumpenWebsite}';

  Future<void> _copyNumber(BuildContext context) async {
    await Clipboard.setData(const ClipboardData(text: _swishNumber));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Swish-numret kopierat'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _openSwish(BuildContext context) async {
    final uri = Uri.parse(_swishUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text(
            'Swish saknas',
            style: TextStyle(color: AppColors.foreground),
          ),
          content: const Text(
            'Det verkar som att Swish-appen inte är installerad på den här enheten. '
            'Du kan kopiera numret och öppna Swish manuellt istället.',
            style: TextStyle(color: AppColors.foreground),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _openWebsite() async {
    final uri = Uri.parse(_websiteUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _shareApp() async {
    await Share.share(_appShareText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            backgroundColor: AppColors.background.withValues(alpha: 0.95),
            elevation: 0,
            title: const Text(
              'STÖD DUMPEN',
              style: TextStyle(
                color: AppColors.foreground,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                fontSize: 18,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Swish-sektion
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.volunteer_activism,
                          color: AppColors.primaryGreen,
                          size: 52,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Swisha till Dumpen',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppColors.foreground,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Ditt stöd gör skillnad',
                          style: TextStyle(color: AppColors.foregroundMuted),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Text(
                            _swishNumber,
                            style: TextStyle(
                              color: AppColors.foreground,
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: QrImageView(
                            data: _swishUrl,
                            size: 180,
                            backgroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _copyNumber(context),
                                icon: const Icon(Icons.copy),
                                label: const Text('Kopiera'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.foreground,
                                  side: const BorderSide(color: AppColors.border),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _openSwish(context),
                                icon: const Icon(Icons.payment),
                                label: const Text('Öppna Swish'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryGreen,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Kräver att Swish-appen är installerad.',
                          style: TextStyle(
                            color: AppColors.grey500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Fakta om Dumpen
                  Text(
                    'Om Dumpen',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.foreground,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 14),
                  const _FactCard(
                    icon: Icons.people,
                    text:
                        'Barnrättsrörelse ledd av Sara Nilsson & Patrik Sjöberg.',
                  ),
                  const _FactCard(
                    icon: Icons.gavel,
                    text:
                        'Mål: Lagändring så planerade övergrepp på fiktiva barn blir straffbara.',
                  ),
                  const _FactCard(
                    icon: Icons.calendar_today_outlined,
                    text: 'Grundad 2021.',
                  ),
                  const _FactCard(
                    icon: Icons.favorite_outline,
                    text:
                        'Föreningen betalar vård för övergreppsutsatta som nekats hjälp.',
                  ),
                  const SizedBox(height: 32),

                  // Sekundära knappar
                  OutlinedButton.icon(
                    onPressed: _shareApp,
                    icon: const Icon(Icons.share),
                    label: const Text('Dela appen'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.foreground,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _openWebsite,
                    icon: const Icon(Icons.open_in_browser),
                    label: const Text('Besök dumpen.se'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.foreground,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FactCard extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FactCard({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryGreen, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.foreground,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
