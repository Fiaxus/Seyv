// Ana ekranın üst satırı: baş harf avatarı, günün saatine göre selamlama,
// kullanıcının adı ve bildirim ikonu.
import 'package:flutter/material.dart';

import 'package:harcama_takip_uygulamasi/core/theme/app_theme.dart';

class GreetingHeader extends StatelessWidget {
  final Future<String?> nameFuture;

  const GreetingHeader({super.key, required this.nameFuture});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) {
      return 'İyi geceler';
    } else if (hour < 12) {
      return 'Günaydın';
    } else if (hour < 18) {
      return 'İyi günler';
    } else {
      return 'İyi akşamlar';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder<String?>(
      future: nameFuture,
      builder: (context, snapshot) {
        final name = snapshot.data ?? '';
        final initials = name.trim().isNotEmpty
            ? name.trim()[0].toUpperCase()
            : '?';

        return Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.brandGradient(context),
              ),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: TextStyle(
                  color: AppTheme.onBrandGradient(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                Text(
                  name.isEmpty ? 'Kullanıcı' : name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.outline),
              ),
              child: const Icon(Icons.notifications_outlined, size: 20),
            ),
          ],
        );
      },
    );
  }
}
