import 'laboratory.dart';

class Exam {
  String course;
  DateTime timestamp;
  String professor;
  Laboratory laboratory;

  Exam({
    required this.course,
    required this.timestamp,
    required this.professor,
    required this.laboratory
  });
}
