import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
          child: Column(
            children: [
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ad-Soyad boş olamaz';
                  }
                  return null;
                },
                controller: nameController,
                decoration: InputDecoration(labelText: 'Ad-Soyad'),
              ),
              SizedBox(height: 16),

              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bu alan boş olamaz';
                  } else if (!value.contains('@')) {
                    return 'Geçersiz e-posta girdiniz';
                  }
                  return null;
                },
                controller: emailController,
                decoration: InputDecoration(labelText: 'E-posta'),
              ),
              SizedBox(height: 16),

              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Şifre boş olamaz';
                  } else if (value.length < 6) {
                    return 'Şifreniz en az 6 karakter uzunluğunda olmalıdır';
                  }
                  return null;
                },
                obscureText: true,
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Şifre'),
              ),
              SizedBox(height: 16),

              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Şifre tekrarı boş olamaz';
                  } else if (value != passwordController.text) {
                    return 'Şifreler eşleşmiyor';
                  }
                  return null;
                },
                obscureText: true,
                controller: againPasswordController,
                decoration: InputDecoration(labelText: 'Tekrar Şifre'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    print('Form geçerli!');
                  }
                },
                child: Text('Kayıt Ol'),
              ),
              SizedBox(height: 16),
              IconButton(
                onPressed: () {
                  context.go('/login');
                },
                icon: Icon(Icons.arrow_back),
              ),
            ],
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
