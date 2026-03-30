class UserProfile {
  final int? id;
  final DateTime quitDate;
  final int cigarettesPerDay;
  final int costPerPack;
  final int cigarettesPerPack;

  UserProfile({
    this.id,
    required this.quitDate,
    required this.cigarettesPerDay,
    required this.costPerPack,
    required this.cigarettesPerPack,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quitDate': quitDate.toIso8601String(),
      'cigarettesPerDay': cigarettesPerDay,
      'costPerPack': costPerPack,
      'cigarettesPerPack': cigarettesPerPack,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      quitDate: DateTime.parse(map['quitDate']),
      cigarettesPerDay: map['cigarettesPerDay'],
      costPerPack: map['costPerPack'],
      cigarettesPerPack: map['cigarettesPerPack'],
    );
  }

  UserProfile copyWith({
    int? id,
    DateTime? quitDate,
    int? cigarettesPerDay,
    int? costPerPack,
    int? cigarettesPerPack,
  }) {
    return UserProfile(
      id: id ?? this.id,
      quitDate: quitDate ?? this.quitDate,
      cigarettesPerDay: cigarettesPerDay ?? this.cigarettesPerDay,
      costPerPack: costPerPack ?? this.costPerPack,
      cigarettesPerPack: cigarettesPerPack ?? this.cigarettesPerPack,
    );
  }

  // Расчёт сэкономленных денег
  int getMoneySaved() {
    final cigarettesSaved = getSmokedCigarettesAvoided();
    final packsSaved = cigarettesSaved / cigarettesPerPack;
    return (packsSaved * costPerPack).toInt();
  }

  // Расчёт дней без курения
  int getDaysSinceQuit() {
    return DateTime.now().difference(quitDate).inDays;
  }

  // Расчёт часов без курения
  int getHoursSinceQuit() {
    return DateTime.now().difference(quitDate).inHours;
  }

  // Расчёт месяцев без курения
  int getMonthsSinceQuit() {
    final now = DateTime.now();
    int months = (now.year - quitDate.year) * 12;
    months += now.month - quitDate.month;
    return months;
  }

  // Расчёт не выкуренных сигарет (новая логика)
  // 1440 минут в сутках / количество сигарет в день = интервал между сигаретами
  // Минуты с момента отказа / интервал = количество не выкуренных сигарет
  double getSmokedCigarettesAvoided() {
    if (cigarettesPerDay == 0) return 0;

    final minutesInDay = 1440; // 24 часа * 60 минут
    final intervalBetweenCigarettes = minutesInDay / cigarettesPerDay;
    final minutesSinceQuit = DateTime.now().difference(quitDate).inMinutes;

    return minutesSinceQuit / intervalBetweenCigarettes;
  }

  // Оценка улучшения здоровья в минутах (примерный расчёт)
  int getHealthImprovement() {
    final hoursSinceQuit = DateTime.now().difference(quitDate).inHours;
    return hoursSinceQuit * 60; // 60 минут здоровья за час отсутствия курения
  }
}
