import 'package:hive/hive.dart';

part 'reminder_model.g.dart';

@HiveType(typeId: 2)
class ReminderModel extends HiveObject {
  @HiveField(0)
  int hour;
  @HiveField(1)
  int minute;

  ReminderModel({required this.hour, required this.minute});

  DateTime nextReminderTime() {
    final now = DateTime.now();
    final todayReminder = DateTime(now.year, now.month, now.day, hour, minute);
    if (todayReminder.isAfter(now)) {
      return todayReminder;
    } else {
      // Next day
      return todayReminder.add(const Duration(days: 1));
    }
  }
}
