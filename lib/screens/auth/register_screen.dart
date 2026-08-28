import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:harcama_takip_uygulamasi/widgets/app_gradient_button.dart';
import 'package:harcama_takip_uygulamasi/widgets/app_text_field.dart';

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
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                IconButton(
                  onPressed: () {
                    context.go('/login');
                  },
                  icon: Icon(Icons.arrow_back),
                ),
                AppTextField(
                  label: 'Ad-Soyad',
                  controller: nameController,
                  icon: Icons.person_outline,
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
                SizedBox(height: 16),

                AppTextField(
                  label: 'Şifre',
                  controller: passwordController,
                  icon: Icons.visibility_outlined,
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
                  icon: Icons.visibility_outlined,
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
                SizedBox(height: 16),
                AppGradientButton(
                  label: 'Kayıt Ol',
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      print('Form geçerli!');
                    }
                  },
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
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
