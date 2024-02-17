import 'package:flutter/material.dart';
import 'package:lab3_main/models/constants/laboratories_list.dart';
import 'package:lab3_main/models/constants/professors_list.dart';
import 'package:lab3_main/models/laboratory.dart';
import '../models/exam_model.dart';

class ExamWidget extends StatefulWidget {
  final Function(Exam) addExam;

  const ExamWidget({required this.addExam, super.key});

  @override
  ExamWidgetState createState() => ExamWidgetState();
}

class ExamWidgetState extends State<ExamWidget> {
  final TextEditingController subjectController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  String? selectedProfessor;
  static const List<String> professors = Professors.professors;
  Laboratory? selectedLaboratory;


  Future<void> _selectDate(BuildContext context) async {
    final DateTime? datePicked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (datePicked != null && datePicked != selectedDate) {
      setState(() {
        selectedDate = datePicked;
      });
    }
  }

  void _selectTime(BuildContext context) async {
    final TimeOfDay? timePicked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDate),
    );

    if (timePicked != null && timePicked != selectedTime) {
      setState(() {
        selectedDate = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          timePicked.hour,
          timePicked.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(labelText: 'Subject'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedProfessor,
              hint: const Text('Select a professor'),
              decoration: const InputDecoration(labelText: 'Professor'),
              items: professors.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedProfessor = newValue;
                });
              },
            ),
            DropdownButtonFormField<Laboratory>(
              value: selectedLaboratory,
              hint: const Text('Select a Laboratory'),
              decoration: const InputDecoration(labelText: 'Professor'),
              items: Laboratories.laboratories.map<DropdownMenuItem<Laboratory>>((Laboratory lab) {
                return DropdownMenuItem<Laboratory>(
                  value: lab,
                  child: Text(lab.name),
                );
              }).toList(),
              onChanged: (Laboratory? newValue) {
                setState(() {
                  selectedLaboratory = newValue;
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Date: ${selectedDate.toLocal().toString().split(' ')[0]}'),
                ElevatedButton(
                  child: const Text('Select Date'),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Time: ${selectedDate.toLocal().toString().split(' ')[1].substring(0, 5)}'),
                ElevatedButton(
                  onPressed: () => _selectTime(context),
                  child: const Text('Select Time'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: selectedProfessor == null ? null : () {
                Exam exam = Exam(
                  course: subjectController.text,
                  timestamp: selectedDate,
                  professor: selectedProfessor!,
                  laboratory: selectedLaboratory!
                );
                widget.addExam(exam);
                Navigator.pop(context);
              },
              child: const Text('Add Exam'),
            ),
          ],
        ),
      ),
    );
  }
}
