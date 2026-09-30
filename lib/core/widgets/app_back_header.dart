// Alt ekranların üst satırı: yuvarlak geri butonu, başlık, alt başlık ve
// isteğe bağlı sağ buton. onBack verilmezse bir önceki sayfaya döner.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppBackHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onBack;
  final Widget? trailing;

  const AppBackHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.onBack,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        AppCircleIconButton(
          icon: Icons.arrow_back,
          onTap: onBack ?? () => context.pop(),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

// Başlık satırlarında kullanılan, ince çerçeveli yuvarlak ikon butonu.
class AppCircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const AppCircleIconButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }
}
