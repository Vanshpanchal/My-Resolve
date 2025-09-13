import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class ReminderHelper {
  static Future<Duration?> getTimeUntilNextReminder() async {
    final box = await Hive.openBox('reminderBox');
    final reminder = box.get('reminder');
    if (reminder == null) return null;
    final now = DateTime.now();
    final hour = reminder['hour'] as int;
    final minute = reminder['minute'] as int;
    final todayReminder = DateTime(now.year, now.month, now.day, hour, minute);
    final nextReminder = todayReminder.isAfter(now)
        ? todayReminder
        : todayReminder.add(const Duration(days: 1));
    return nextReminder.difference(now);
  }

  static String formatDuration(Duration? duration) {
    if (duration == null) return '00:00:00';
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    return '${hours.toString().padLeft(2, '0')} : ${minutes.toString().padLeft(2, '0')} : ${seconds.toString().padLeft(2, '0')}';
  }
}
