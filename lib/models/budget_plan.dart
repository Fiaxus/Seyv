class BudgetPlan {
  final double monthly;

  /// Sadece limiti olan kategoriler tutulur. Limit 0 = kategori map'te yok.
  final Map<String, double> categoryLimits;

  const BudgetPlan({required this.monthly, this.categoryLimits = const {}});

  static const empty = BudgetPlan(monthly: 0);

  /// Tüm kategori limitlerinin toplamı.
  double get allocated =>
      categoryLimits.values.fold(0.0, (sum, value) => sum + value);

  /// Aylık bütçeden henüz dağıtılmamış kalan tutar.
  double get unallocated => monthly - allocated;

  /// Kural: dağıtılan toplam, aylık bütçeyi aşamaz.
  bool get isValid => allocated <= monthly;

  bool get hasMonthly => monthly > 0;

  int get limitedCategoryCount => categoryLimits.length;

  /// Kategorinin limiti, yoksa null.
  double? limitFor(String category) => categoryLimits[category];

  /// Bu kategoriye verilebilecek en yüksek limit.
  /// Kategorinin KENDİ mevcut değeri hesaptan çıkarılır; aksi halde
  /// mevcut bir limiti düşürmek bile engellenirdi.
  double maxFor(String category) {
    final current = categoryLimits[category] ?? 0;
    return monthly - (allocated - current);
  }

  BudgetPlan copyWith({double? monthly, Map<String, double>? categoryLimits}) {
    return BudgetPlan(
      monthly: monthly ?? this.monthly,
      categoryLimits: categoryLimits ?? this.categoryLimits,
    );
  }

  /// Tek bir kategorinin limitini değiştirir. 0 veya altı = limiti kaldır.
  BudgetPlan withLimit(String category, double amount) {
    final updated = Map<String, double>.from(categoryLimits);
    if (amount <= 0) {
      updated.remove(category);
    } else {
      updated[category] = amount;
    }
    return copyWith(categoryLimits: updated);
  }

  factory BudgetPlan.fromMap(Map<String, dynamic>? map) {
    if (map == null) return BudgetPlan.empty;

    final monthly = (map['monthlyBudget'] as num?)?.toDouble() ?? 0;

    final limits = <String, double>{};
    final raw = map['categoryBudgets'];
    if (raw is Map) {
      raw.forEach((key, value) {
        if (key is String && value is num && value > 0) {
          limits[key] = value.toDouble();
        }
      });
    }

    return BudgetPlan(monthly: monthly, categoryLimits: limits);
  }

  Map<String, dynamic> toMap() {
    return {
      'monthlyBudget': monthly,
      'categoryBudgets': Map<String, double>.from(categoryLimits),
    };
  }

  // Taslak ile kayıtlı plan karşılaştırılırken (kaydedilmemiş değişiklik
  // var mı?) içerik karşılaştırması gerekiyor, referans değil.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BudgetPlan) return false;
    if (other.monthly != monthly) return false;
    if (other.categoryLimits.length != categoryLimits.length) return false;
    for (final entry in categoryLimits.entries) {
      if (other.categoryLimits[entry.key] != entry.value) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    monthly,
    Object.hashAllUnordered(
      categoryLimits.entries.map((e) => Object.hash(e.key, e.value)),
    ),
  );
}