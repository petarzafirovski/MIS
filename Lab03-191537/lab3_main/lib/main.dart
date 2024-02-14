import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'package:lab3_main/widgets/exam_widget.dart';
import 'configs/firebase_options.dart';
import 'models/constants/professors_list.dart';
import 'widgets/calendar_widget.dart';
import 'models/exam_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'configs/notification_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await AwesomeNotifications().initialize(null, [
    NotificationChannel(
      channelGroupKey: "channel_group_key",
      channelKey: "channel_key",
      channelName: "basic_notif",
      channelDescription: "local push notifications for lab4",
    )
  ], channelGroups: [
    NotificationChannelGroup(
        channelGroupKey: "channel_group_key", channelGroupName: "channel_group")
  ]);

  bool isAllowedToSendNotification =
  await AwesomeNotifications().isNotificationAllowed();

  if (!isAllowedToSendNotification) {
    AwesomeNotifications().requestPermissionToSendNotifications();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const MainListScreen(),
        '/login': (context) => const AuthScreen(isLogin: true),
        '/register': (context) => const AuthScreen(isLogin: false),
      },
    );
  }
}

class MainListScreen extends StatefulWidget {
  const MainListScreen({super.key});

  @override
  MainListScreenState createState() => MainListScreenState();
}

class MainListScreenState extends State<MainListScreen> {
  final List<Exam> exams = [
    Exam(course: 'МИС', timestamp: DateTime(2024, 02, 17), professor: Professors.professors[0]),
    Exam(course: 'Вовед во науката за податоци', timestamp: DateTime(2023, 12, 31), professor: Professors.professors[1]),
  ];

  @override
  void initState() {
    super.initState();
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: CustomNotificationHandler.handleUserAction,
      onDismissActionReceivedMethod: CustomNotificationHandler.handleNotificationDismissed,
      onNotificationCreatedMethod: CustomNotificationHandler.handleNotificationCreated,
      onNotificationDisplayedMethod: CustomNotificationHandler.handleNotificationDisplayed);
    _scheduleNotificationsForExistingExams();
  }

  void _scheduleNotificationsForExistingExams() {
    for (int i = 0; i < exams.length; i++) {
      _scheduleNotification(exams[i]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exams'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: _openCalendar,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => FirebaseAuth.instance.currentUser != null
                ? _addExamFunction(context)
                : _navigateToSignInPage(context),
          ),
          IconButton(
            icon: const Icon(Icons.login),
            onPressed: _signOut,
          ),
        ],
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: exams.length,
        itemBuilder: (context, index) {
          final course = exams[index].course;

          var timestamp = exams[index].timestamp;
          final date = DateTime(timestamp.year, timestamp.month, timestamp.day);
          final dateString = DateFormat('yyyy-MM-dd').format(date);

          final professor = exams[index].professor;

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Професор: $professor',
                    style: const TextStyle(fontWeight: FontWeight.w500,color: Colors.brown),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    dateString,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _openCalendar() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CalendarWidget(exams: exams),
      ),
    );
  }

  Future<void> _addExamFunction(BuildContext context) async {
    return showModalBottomSheet(
        context: context,
        builder: (_) {
          return GestureDetector(
            onTap: () {},
            behavior: HitTestBehavior.opaque,
            child: ExamWidget(
              addExam: _addExam,
            ),
          );
        });
  }

  void _addExam(Exam exam) {
    setState(() {
      exams.add(exam);
      _scheduleNotification(exam);
    });
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  void _navigateToSignInPage(BuildContext context) {
    Future.delayed(Duration.zero, () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  void _scheduleNotification(Exam exam) {
    final int notificationId = exams.indexOf(exam);

    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notificationId,
        channelKey: "channel_key",
        title: exam.course,
        body: "Известување за нов испит",
      ),
    );
  }

}

class AuthScreen extends StatefulWidget {
  final bool isLogin;

  const AuthScreen({super.key, required this.isLogin});

  @override
  AuthScreenState createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
  GlobalKey<ScaffoldMessengerState>();

  Future<void> _authAction() async {
    try {
      if (widget.isLogin) {
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        _showSuccessDialog(
            "Login Successful", "You have successfully logged in!");
        _navigateToHome();
      } else {
        await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        _showSuccessDialog(
            "Registration Successful", "You have successfully registered!");
        _navigateToLogin();
      }
    } catch (e) {
      _showErrorDialog(
          "Authentication Error", "Error during authentication: $e");
    }
  }

  void _showSuccessDialog(String title, String message) {
    _scaffoldKey.currentState?.showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    ));
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _navigateToHome() {
    Future.delayed(Duration.zero, () {
      Navigator.pushReplacementNamed(context, '/');
    });
  }

  void _navigateToLogin() {
    Future.delayed(Duration.zero, () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  void _navigateToRegister() {
    Future.delayed(Duration.zero, () {
      Navigator.pushReplacementNamed(context, '/register');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.isLogin ? const Text("Login") : const Text("Register"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _authAction,
              child: Text(widget.isLogin ? "Sign In" : "Register"),
            ),
            if (!widget.isLogin)
              ElevatedButton(
                onPressed: _navigateToLogin,
                child: const Text('Already have an account? Login'),
              ),
            if (widget.isLogin)
              ElevatedButton(
                onPressed: _navigateToRegister,
                child: const Text('Create an account'),
              ),
            TextButton(
              onPressed: _navigateToHome,
              child: const Text('Back to Main Screen'),
            ),
          ],
        ),
      ),
    );
  }
}
