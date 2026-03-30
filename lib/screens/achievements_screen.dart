import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_profile_provider.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProfileProvider>(
      builder: (context, provider, _) {
        if (!provider.hasProfile) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Достижения'),
              backgroundColor: const Color(0xFF4CAF50),
            ),
            body: const Center(child: Text('Сначала создайте профиль')),
          );
        }

        final hoursSinceQuit = provider.profile!.getHoursSinceQuit();

        // Достижения основаны на времени без курения
        final achievements = [
          _Achievement(
            title: '1 час',
            description: 'Нормализация кровяного давления и пульса.',
            iconData: Icons.favorite,
            unlockedAt: 1,
          ),
          _Achievement(
            title: '2 часа',
            description: 'Улучшение циркуляции крови.',
            iconData: Icons.favorite,
            unlockedAt: 2,
          ),
          _Achievement(
            title: '4 часа',
            description: 'Температура конечностей возвращается к норме.',
            iconData: Icons.favorite,
            unlockedAt: 4,
          ),
          _Achievement(
            title: '6 часов',
            description:
                'Неприятный запах изо рта становится менее выраженным.',
            iconData: Icons.favorite,
            unlockedAt: 6,
          ),
          _Achievement(
            title: '8 часов',
            description: 'Нормализация уровня кислорода в крови.',
            iconData: Icons.favorite,
            unlockedAt: 8,
          ),
          _Achievement(
            title: '10 часов',
            description: 'Улучшение транспортной функции эритроцитов.',
            iconData: Icons.favorite,
            unlockedAt: 10,
          ),
          _Achievement(
            title: '12 часов',
            description: 'Уровень угарного газа в крови снижается до нормы.',
            iconData: Icons.favorite,
            unlockedAt: 12,
          ),
          _Achievement(
            title: '24 часа',
            description: 'Снижение риска сердечного приступа.',
            iconData: Icons.favorite,
            unlockedAt: 24,
          ),
          _Achievement(
            title: '36 часов',
            description: 'Улучшение вкусовых ощущений и обоняния.',
            iconData: Icons.favorite,
            unlockedAt: 36,
          ),
          _Achievement(
            title: '2 дня',
            description: 'Нервные окончания начинают восстанавливаться.',
            iconData: Icons.favorite,
            unlockedAt: 48,
          ),
          _Achievement(
            title: '3 дня',
            description: 'Улучшение дыхания и повышение энергии.',
            iconData: Icons.favorite,
            unlockedAt: 72,
          ),
          _Achievement(
            title: '4 дня',
            description: 'Повышение концентрации внимания.',
            iconData: Icons.favorite,
            unlockedAt: 96,
          ),
          _Achievement(
            title: '5 дней',
            description: 'Активное восстановление легочных функций.',
            iconData: Icons.favorite,
            unlockedAt: 120,
          ),
          _Achievement(
            title: '6 дней',
            description: 'Улучшение цвета кожи и общего тонуса.',
            iconData: Icons.favorite,
            unlockedAt: 144,
          ),
          _Achievement(
            title: '1 неделя',
            description: 'Снижение тяги к курению и улучшение кровообращения.',
            iconData: Icons.favorite,
            unlockedAt: 168,
          ),
          _Achievement(
            title: '2 недели',
            description: 'Улучшение функции легких и кровообращения.',
            iconData: Icons.favorite,
            unlockedAt: 336,
          ),
          _Achievement(
            title: '3 недели',
            description: 'Значительное снижение кашля и одышки.',
            iconData: Icons.favorite,
            unlockedAt: 504,
          ),
          _Achievement(
            title: '1 месяц',
            description: 'Значительное улучшение функции лёгких.',
            iconData: Icons.favorite,
            unlockedAt: 30 * 24,
          ),
          _Achievement(
            title: '2 месяца',
            description: 'Улучшение работы иммунной системы.',
            iconData: Icons.favorite,
            unlockedAt: 60 * 24,
          ),
          _Achievement(
            title: '3 месяца',
            description: 'Обновление слизистой оболочки лёгких.',
            iconData: Icons.favorite,
            unlockedAt: 90 * 24,
          ),
          _Achievement(
            title: '4 месяца',
            description: 'Снижение риска инфекций дыхательных путей.',
            iconData: Icons.favorite,
            unlockedAt: 120 * 24,
          ),
          _Achievement(
            title: '5 месяцев',
            description: 'Восстановление эластичности сосудов.',
            iconData: Icons.favorite,
            unlockedAt: 150 * 24,
          ),
          _Achievement(
            title: '6 месяцев',
            description: 'Значительное улучшение здоровья.',
            iconData: Icons.favorite,
            unlockedAt: 180 * 24,
          ),
          _Achievement(
            title: '7 месяцев',
            description: 'Укрепление дыхательной системы.',
            iconData: Icons.favorite,
            unlockedAt: 210 * 24,
          ),
          _Achievement(
            title: '8 месяцев',
            description: 'Восстановление здорового цвета лица.',
            iconData: Icons.favorite,
            unlockedAt: 240 * 24,
          ),
          _Achievement(
            title: '9 месяцев',
            description: 'Полное восстановление ресничек легких.',
            iconData: Icons.favorite,
            unlockedAt: 270 * 24,
          ),
          _Achievement(
            title: '10 месяцев',
            description: 'Снижение риска развития рака.',
            iconData: Icons.favorite,
            unlockedAt: 300 * 24,
          ),
          _Achievement(
            title: '11 месяцев',
            description: 'Практически полное восстановление организма.',
            iconData: Icons.favorite,
            unlockedAt: 330 * 24,
          ),
          _Achievement(
            title: '1 год',
            description: 'Риск проблем с сердцем снижается на 50%.',
            iconData: Icons.favorite,
            unlockedAt: 365 * 24,
          ),
          _Achievement(
            title: '2 года',
            description: 'Риск инсульта снижается как у некурящего.',
            iconData: Icons.favorite,
            unlockedAt: 730 * 24,
          ),
          _Achievement(
            title: '3 года',
            description: 'Риск инфаркта снижается до уровня некурящего.',
            iconData: Icons.favorite,
            unlockedAt: 1095 * 24,
          ),
          _Achievement(
            title: '4 года',
            description: 'Полное восстановление сосудистой системы.',
            iconData: Icons.favorite,
            unlockedAt: 1460 * 24,
          ),
          _Achievement(
            title: '5 лет',
            description: 'Риск рака легких снижается в 2 раза.',
            iconData: Icons.favorite,
            unlockedAt: 1825 * 24,
          ),
          _Achievement(
            title: '10 лет',
            description: 'Риск рака легких как у некурящего человека.',
            iconData: Icons.favorite,
            unlockedAt: 3650 * 24,
          ),
          _Achievement(
            title: '15 лет',
            description: 'Полное восстановление здоровья, как у некурящего.',
            iconData: Icons.favorite,
            unlockedAt: 5475 * 24,
          ),
        ];

        return Scaffold(
          appBar: AppBar(
            title: const Text('Достижения'),
            backgroundColor: const Color(0xFF4CAF50),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Ваш прогресс в отказе от курения',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 20),
                  ...achievements.map((achievement) {
                    final isUnlocked = hoursSinceQuit >= achievement.unlockedAt;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _AchievementCard(
                        achievement: achievement,
                        isUnlocked: isUnlocked,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Achievement {
  final String title;
  final String description;
  final IconData iconData;
  final int unlockedAt; // в часах

  _Achievement({
    required this.title,
    required this.description,
    required this.iconData,
    required this.unlockedAt,
  });
}

class _AchievementCard extends StatelessWidget {
  final _Achievement achievement;
  final bool isUnlocked;

  const _AchievementCard({required this.achievement, required this.isUnlocked});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnlocked ? Colors.green[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnlocked ? Colors.green : Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isUnlocked ? const Color(0xFF4CAF50) : Colors.grey[400],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.favorite, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (isUnlocked)
            Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 28),
        ],
      ),
    );
  }
}
