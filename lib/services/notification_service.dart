import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Список всех достижений в часах
  static const List<int> achievementMilestones = [
    1, // 1 час
    2, // 2 часа
    4, // 4 часа
    6, // 6 часов
    8, // 8 часов
    10, // 10 часов
    12, // 12 часов
    24, // 1 день
    36, // 36 часов
    48, // 2 дня
    72, // 3 дня
    96, // 4 дня
    120, // 5 дней
    144, // 6 дней
    168, // 1 неделя
    336, // 2 недели
    504, // 3 недели
    720, // 1 месяц (30 дней)
    1440, // 2 месяца
    2160, // 3 месяца
    2880, // 4 месяца
    3600, // 5 месяцев
    4320, // 6 месяцев
    5040, // 7 месяцев
    5760, // 8 месяцев
    6480, // 9 месяцев
    7200, // 10 месяцев
    7920, // 11 месяцев
    8760, // 1 год (365 дней)
    17520, // 2 года
    26280, // 3 года
    35040, // 4 года
    43800, // 5 лет
    87600, // 10 лет
    131400, // 15 лет
  ];

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);

    // Запрос разрешений для Android 13+
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }

    final iosPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  Future<void> checkAndShowAchievementNotifications(int hoursSinceQuit) async {
    final prefs = await SharedPreferences.getInstance();
    final lastNotifiedHour = prefs.getInt('last_notified_achievement') ?? 0;

    // Проверяем все достижения, которые были достигнуты с последнего раза
    for (final milestone in achievementMilestones) {
      if (hoursSinceQuit >= milestone && lastNotifiedHour < milestone) {
        await _showAchievementNotification(milestone);
        // Сохраняем последнее уведомленное достижение
        await prefs.setInt('last_notified_achievement', milestone);
        break; // Показываем только одно уведомление за раз
      }
    }
  }

  Future<void> _showAchievementNotification(int hours) async {
    final title = _getAchievementTitle(hours);
    final body = _getAchievementDescription(hours);

    const androidDetails = AndroidNotificationDetails(
      'achievements_channel',
      'Достижения',
      channelDescription: 'Уведомления о достижениях в отказе от курения',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      hours, // используем hours как ID
      '🎉 Новое достижение: $title',
      body,
      details,
    );
  }

  String _getAchievementTitle(int hours) {
    switch (hours) {
      case 1:
        return '1 час';
      case 2:
        return '2 часа';
      case 4:
        return '4 часа';
      case 6:
        return '6 часов';
      case 8:
        return '8 часов';
      case 10:
        return '10 часов';
      case 12:
        return '12 часов';
      case 24:
        return '24 часа';
      case 36:
        return '36 часов';
      case 48:
        return '2 дня';
      case 72:
        return '3 дня';
      case 96:
        return '4 дня';
      case 120:
        return '5 дней';
      case 144:
        return '6 дней';
      case 168:
        return '1 неделя';
      case 336:
        return '2 недели';
      case 504:
        return '3 недели';
      case 720:
        return '1 месяц';
      case 1440:
        return '2 месяца';
      case 2160:
        return '3 месяца';
      case 2880:
        return '4 месяца';
      case 3600:
        return '5 месяцев';
      case 4320:
        return '6 месяцев';
      case 5040:
        return '7 месяцев';
      case 5760:
        return '8 месяцев';
      case 6480:
        return '9 месяцев';
      case 7200:
        return '10 месяцев';
      case 7920:
        return '11 месяцев';
      case 8760:
        return '1 год';
      case 17520:
        return '2 года';
      case 26280:
        return '3 года';
      case 35040:
        return '4 года';
      case 43800:
        return '5 лет';
      case 87600:
        return '10 лет';
      case 131400:
        return '15 лет';
      default:
        return '$hours часов';
    }
  }

  String _getAchievementDescription(int hours) {
    switch (hours) {
      case 1:
        return 'Нормализация кровяного давления и пульса.';
      case 2:
        return 'Улучшение циркуляции крови.';
      case 4:
        return 'Температура конечностей возвращается к норме.';
      case 6:
        return 'Неприятный запах изо рта становится менее выраженным.';
      case 8:
        return 'Нормализация уровня кислорода в крови.';
      case 10:
        return 'Улучшение транспортной функции эритроцитов.';
      case 12:
        return 'Уровень угарного газа в крови снижается до нормы.';
      case 24:
        return 'Снижение риска сердечного приступа.';
      case 36:
        return 'Улучшение вкусовых ощущений и обоняния.';
      case 48:
        return 'Нервные окончания начинают восстанавливаться.';
      case 72:
        return 'Улучшение дыхания и повышение энергии.';
      case 96:
        return 'Повышение концентрации внимания.';
      case 120:
        return 'Активное восстановление легочных функций.';
      case 144:
        return 'Улучшение цвета кожи и общего тонуса.';
      case 168:
        return 'Снижение тяги к курению и улучшение кровообращения.';
      case 336:
        return 'Улучшение функции легких и кровообращения.';
      case 504:
        return 'Значительное снижение кашля и одышки.';
      case 720:
        return 'Значительное улучшение функции лёгких.';
      case 1440:
        return 'Улучшение работы иммунной системы.';
      case 2160:
        return 'Обновление слизистой оболочки лёгких.';
      case 2880:
        return 'Снижение риска инфекций дыхательных путей.';
      case 3600:
        return 'Восстановление эластичности сосудов.';
      case 4320:
        return 'Значительное улучшение здоровья.';
      case 5040:
        return 'Укрепление дыхательной системы.';
      case 5760:
        return 'Восстановление здорового цвета лица.';
      case 6480:
        return 'Полное восстановление ресничек легких.';
      case 7200:
        return 'Снижение риска развития рака.';
      case 7920:
        return 'Практически полное восстановление организма.';
      case 8760:
        return 'Риск проблем с сердцем снижается на 50%.';
      case 17520:
        return 'Риск инсульта снижается как у некурящего.';
      case 26280:
        return 'Риск инфаркта снижается до уровня некурящего.';
      case 35040:
        return 'Полное восстановление сосудистой системы.';
      case 43800:
        return 'Риск рака легких снижается в 2 раза.';
      case 87600:
        return 'Риск рака легких как у некурящего человека.';
      case 131400:
        return 'Полное восстановление здоровья, как у некурящего.';
      default:
        return 'Продолжайте в том же духе!';
    }
  }

  Future<void> resetNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_notified_achievement');
  }
}
