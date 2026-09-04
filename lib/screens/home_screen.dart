import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/category_data.dart';
import '../widgets/category_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final userName = 'Berkay';
  final userInitials = 'NB';
  final List<CategoryData> mockCategories = const [
    CategoryData(
      icon: Icons.shopping_cart_outlined,
      categoryName: 'Market',
      amount: '3.250 ₺',
      accentColor: Color(0xFF08A88A),
    ),
    CategoryData(
      icon: Icons.restaurant_outlined,
      categoryName: 'Yemek',
      amount: '2.400 ₺',
      accentColor: Color(0xFFE0912F),
    ),
    CategoryData(
      icon: Icons.receipt_long_outlined,
      categoryName: 'Fatura',
      amount: '3.500 ₺',
      accentColor: Color(0xFF9B7FE0),
    ),
  ];

  String getGreeting() {
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

  String getCurrentMonthYear() {
    final now = DateTime.now();
    return DateFormat('MMMM yyyy', 'tr_TR').format(now);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      userInitials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getGreeting(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                      Text(
                        userName,
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
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    child: const Icon(Icons.notifications_outlined, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      const Color(0xFF0D2B2B),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${getCurrentMonthYear()} · Toplam harcama',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'TRY',
                            style: TextStyle(color: Colors.white, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '12.450,00 ₺',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.trending_down,
                          color: Colors.greenAccent[100],
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Geçen aya göre %8 daha az',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Aylık bütçe 20.000 ₺',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                          ),
                        ),
                        const Text(
                          'Kalan 7.550 ₺',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: 0.62,
                        minHeight: 8,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Kategori özeti',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    'Tümü',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 130,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: mockCategories.length,
                  itemBuilder: (context, index) {
                    final data = mockCategories[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: SizedBox(
                        width: 110,
                        child: CategoryCard(
                          icon: data.icon,
                          categoryName: data.categoryName,
                          amount: data.amount,
                          accentColor: data.accentColor,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
