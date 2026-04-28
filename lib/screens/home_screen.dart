import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/user_profile_provider.dart';
import '../services/notification_service.dart';
import 'profile_edit_screen.dart';

String _formatDuration(DateTime quitDate) {
  final diff = DateTime.now().difference(quitDate);
  if (diff.inMinutes < 60) {
    return '${diff.inMinutes} мин';
  } else if (diff.inHours < 24) {
    final h = diff.inHours;
    final m = diff.inMinutes % 60;
    return m > 0 ? '$hч $mм' : '$hч';
  } else if (diff.inDays < 30) {
    final d = diff.inDays;
    final h = diff.inHours % 24;
    return h > 0 ? '$d д $h ч' : '$d д';
  } else {
    final months = diff.inDays ~/ 30;
    final days = diff.inDays % 30;
    return days > 0 ? '$months мес $days д' : '$months мес';
  }
}

String _formatHealth(double minutes) {
  if (minutes < 60) {
    return '${minutes.round()} м';
  } else if (minutes < 1440) {
    return '${(minutes / 60).floor()} ч';
  } else {
    return '${(minutes / 1440).floor()} д';
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Обновляем экран каждую секунду
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
        // Проверяем достижения для уведомлений
        _checkAchievements();
      }
    });
    // Проверяем достижения при запуске
    _checkAchievements();
  }

  void _checkAchievements() {
    final provider = context.read<UserProfileProvider>();
    if (provider.hasProfile) {
      final hoursSinceQuit = provider.profile!.getHoursSinceQuit();
      NotificationService().checkAndShowAchievementNotifications(
        hoursSinceQuit,
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProfileProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!provider.hasProfile) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Image.asset('assets/logo.png', fit: BoxFit.contain),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Don\'t Smoke',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      'Давайте начнём ваш путь к здоровью!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              const ProfileEditScreen(isNewUser: true),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                    ),
                    child: const Text(
                      'Начать',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final timeLabel = _formatDuration(provider.profile!.quitDate);
        final moneySaved = provider.getMoneySaved();
        final cigarettesAvoided = provider.getSmokedCigarettesAvoided();
        final healthImprovement = provider.getHealthImprovement();

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Image.asset(
                              'assets/logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Dont Smoke',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Ваш прогресс в отказе от курения',
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Прогресс',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 12),
                        // Месяцы и дни
                        IntrinsicHeight(
                          child: Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  title: timeLabel,
                                  subtitle: 'Время без курения',
                                  icon: Icons.access_time_filled,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatCard(
                                  title: moneySaved.toString(),
                                  iconWidget: Image.asset(
                                    'assets/money_icon.png',
                                    width: 32,
                                    height: 32,
                                  ),
                                  subtitle: 'Сэкономлено',
                                  icon: Icons.attach_money_outlined,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Сигареты и здоровье
                        IntrinsicHeight(
                          child: Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  title: NumberFormat.decimalPattern(
                                    'ru_RU',
                                  ).format(cigarettesAvoided.round()),
                                  subtitle: 'Сигарет не выкурено',
                                  icon: Icons.smoke_free,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatCard(
                                  title: _formatHealth(healthImprovement),
                                  subtitle: 'Жизнь продлена',
                                  icon: Icons.favorite,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? iconWidget;

  const _StatCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.iconWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          iconWidget ?? Icon(icon, size: 32, color: Colors.green),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
