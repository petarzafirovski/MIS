import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart'; // Add this import for date formatting
import '../models/exam_model.dart'; // Ensure this import matches the location of your Exam model

class CalendarWidget extends StatefulWidget {
  final List<Exam> exams;

  const CalendarWidget({Key? key, required this.exams}) : super(key: key);

  @override
  CalendarWidgetState createState() => CalendarWidgetState();
}

class CalendarWidgetState extends State<CalendarWidget> {
  late Map<DateTime, List<Exam>> _events;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _events = {};

    for (var exam in widget.exams) {
      var examDate = DateTime(exam.timestamp.year, exam.timestamp.month, exam.timestamp.day);
      if (_events.containsKey(examDate)) {
        _events[examDate]!.add(exam);
      } else {
        _events[examDate] = [exam];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exams Calendar'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: (day) => _events[DateTime(day.year, day.month, day.day)] ?? [],
            calendarFormat: CalendarFormat.month,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
              markerDecoration: BoxDecoration(color: Colors.brown, shape: BoxShape.rectangle),
            ),
              onDaySelected: (selectedDay, focusedDay) {
                // Normalize selectedDay to midnight
                DateTime normalizedSelectedDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);

                setState(() {
                  _selectedDay = normalizedSelectedDay; // Use the normalized date
                  _focusedDay = focusedDay;
                });

                // Use the normalized date for dialog lookup
                _showExamsDialog(context, normalizedSelectedDay);
              },
          ),
        ],
      ),
    );
  }

  void _showExamsDialog(BuildContext context, DateTime selectedDay) {
    final selectedExams = _events[selectedDay] ?? [];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Exams on ${DateFormat('yyyy-MM-dd').format(selectedDay)}'),
        content: SingleChildScrollView(
          child: ListBody(
            children: selectedExams.isEmpty
                ? [const Text("No exams on this day.")]
                : selectedExams
                .map((exam) => Text('${exam.course} кај проф. ${exam.professor}, лабораторија: ${exam.laboratory.name}'))
                .toList(),
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Close'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
