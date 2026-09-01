import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:harcama_takip_uygulamasi/widgets/app_gradient_button.dart';
import 'package:harcama_takip_uygulamasi/widgets/app_text_field.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/auth/auth_cubit.dart';
import '../../blocs/auth/auth_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController againPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          context.go('/home');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }
      },

      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(30),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: IconButton(
                              onPressed: () {
                                context.go('/login');
                              },
                              icon: const Icon(Icons.arrow_back, size: 20),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hesap Oluştur',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                    ),
                              ),
                              Text(
                                '30 saniyede başla',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.6),
                                      fontSize: 16,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      AppTextField(
                        label: 'Ad-Soyad',
                        controller: nameController,
                        icon: LucideIcons.user,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ad-Soyad boş olamaz';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      AppTextField(
                        label: 'E-posta',
                        controller: emailController,
                        icon: LucideIcons.mail,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Bu alan boş olamaz';
                          } else if (!value.contains('@')) {
                            return 'Geçersiz e-posta girdiniz';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      AppTextField(
                        label: 'Şifre',
                        controller: passwordController,
                        icon: LucideIcons.lock,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Şifre boş olamaz';
                          } else if (value.length < 6) {
                            return 'Şifreniz en az 6 karakter uzunluğunda olmalıdır';
                          }
                          return null;
                        },
                        obscureText: true,
                      ),
                      SizedBox(height: 16),

                      AppTextField(
                        label: 'Tekrar Şifre',
                        controller: againPasswordController,
                        icon: LucideIcons.lock,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Şifre tekrarı boş olamaz';
                          } else if (value != passwordController.text) {
                            return 'Şifreler eşleşmiyor';
                          }
                          return null;
                        },
                        obscureText: true,
                      ),
                      SizedBox(height: 40),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface
                              .withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                            children: const [
                              TextSpan(text: 'Devam ederek '),
                              TextSpan(
                                text: 'Kullanım Koşulları',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: ' ve '),
                              TextSpan(
                                text: 'Gizlilik Politikası',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: '\'nı kabul etmiş olursun.'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      AppGradientButton(
                        label: 'Kayıt Ol',
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            context.read<AuthCubit>().signUp(
                              email: emailController.text,
                              password: passwordController.text,
                            );
                          }
                        },
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    againPasswordController.dispose();
    super.dispose();
  }
}
