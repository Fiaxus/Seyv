import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:harcama_takip_uygulamasi/widgets/app_gradient_button.dart';
import 'package:harcama_takip_uygulamasi/widgets/app_text_field.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40),
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(LucideIcons.wallet, color: Colors.white),
                ),
                const SizedBox(height: 28),
                Text(
                  'Tekrar hoş geldin',
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800, fontSize: 26),
                ),
                const SizedBox(height: 6),
                Text(
                  'Bütçeni takip etmeye kaldığın yerden devam et.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface
                        .withValues(alpha: 0.6),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 32),
                AppTextField(
                  label: 'E-posta',
                  controller: emailController,
                  icon: Icons.mail_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bu alan boş olamaz';
                    } else if (!value.contains('@')) {
                      return 'Geçersiz e-posta girdiniz';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                AppTextField(
                  label: 'Şifre',
                  controller: passwordController,
                  icon: Icons.visibility_outlined,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Şifre boş olamaz';
                    } else if (value.length < 6) {
                      return 'Şifreniz en az 6 karakter uzunluğunda olmalıdır';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      //şifre sıfırlama
                    },
                    child: const Text(
                      'Şifremi unuttum',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                AppGradientButton(
                  label: 'Giriş Yap',
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      print('Form Geçerli!');
                    }
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Theme.of(context).colorScheme.onSurface
                            .withValues(alpha: 0.2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'veya',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Theme.of(context).colorScheme.onSurface
                            .withValues(alpha: 0.2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Google ile giriş ekle
                    },
                    icon: const Icon(Icons.g_mobiledata, size: 40),
                    label: const Text(
                      'Google ile devam et',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    context.go('/register');
                  },
                  child: Text('Hesabın yok mu? Kayıt Ol'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
