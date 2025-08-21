import 'package:myresolve/Utils/PactStatusEnum.dart';

class Pact {
  final String title;
  final String creator;
  final DateTime createdAt;
  final int days;
  final PactStatus status;

  const Pact({
    required this.title,
    required this.creator,
    required this.createdAt,
    required this.days,
    required this.status,
  });
}