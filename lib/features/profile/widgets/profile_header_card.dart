// Profil ekranının üstündeki kart: baş harf avatarı, isim, e-posta ve
// hesabın doğrulanma durumunu gösteren rozet.
import 'package:flutter/material.dart';

import 'package:harcama_takip_uygulamasi/core/theme/app_theme.dart';

class ProfileHeaderCard extends StatelessWidget {
  final Future<String?> nameFuture;
  final String email;
  final bool isVerified;
  final VoidCallback onVerifyTap;

  const ProfileHeaderCard({
    super.key,
    required this.nameFuture,
    required this.email,
    required this.isVerified,
    required this.onVerifyTap,
  });

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline),
      ),
      child: FutureBuilder<String?>(
        future: nameFuture,
        builder: (context, snapshot) {
          final name = snapshot.data ?? '';
          return Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.brandGradient(context),
                ),
                alignment: Alignment.center,
                child: Text(
                  _initials(name),
                  style: TextStyle(
                    color: AppTheme.onBrandGradient(context),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isEmpty ? 'İsimsiz Kullanıcı' : name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _VerifiedBadge(
                      isVerified: isVerified,
                      onTap: isVerified ? null : onVerifyTap,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Doğrulanmamış hesapta dokunulabilir; dokununca doğrulama akışı başlar.
class _VerifiedBadge extends StatelessWidget {
  final bool isVerified;
  final VoidCallback? onTap;

  const _VerifiedBadge({required this.isVerified, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isVerified ? colorScheme.primary : colorScheme.secondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isVerified ? 'Doğrulanmış hesap' : 'Doğrulanmamış hesap',
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (!isVerified) ...[
              const SizedBox(width: 4),
              Icon(Icons.refresh, size: 12, color: color),
            ],
          ],
        ),
      ),
    );
  }
}
