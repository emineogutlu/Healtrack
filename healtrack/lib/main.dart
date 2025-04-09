import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healtrack/pages/choosing_a_dietitian.dart';
import 'package:healtrack/pages/make%20_an_appointment.dart';
import 'package:healtrack/pages/view_profile.dart';
import 'firebase_options.dart';
import 'package:healtrack/pages/first_page.dart';
import 'package:healtrack/pages/user_recognition.dart';
import 'package:healtrack/pages/user_recognition_1.dart';
import 'package:healtrack/pages/user_recognition_2.dart';
import 'package:healtrack/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HealTrack',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const FirstPage(),
        '/login': (context) => LoginRegisterPage(),
        '/user-recognition': (context) => UserRecognition(),
        '/user-recognition-1': (context) => UserRecognition1(),
        '/user-recognition-2': (context) => UserRecognition2(),
        '/home': (context) => HomePage(),
        '/choosing-a-dietitian': (context) => ChoosingADietitian(),
        '/make-an-appointment': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments as Map<String, String>;//veri ileitmi 
          return MakeAppointmentPage(
            dietitianId: args['dietitianId']!,
            dietitianName: args['dietitianName']!,
          );
        },
        '/view-profile': (context) {
          final dietitianId =
              ModalRoute.of(context)?.settings.arguments as String?;
          return ViewProfile(dietitianId: dietitianId ?? '');
        },
      },
    );
  }
}

class LoginRegisterPage extends StatefulWidget {
  const LoginRegisterPage({super.key});

  @override
  State<LoginRegisterPage> createState() => _LoginRegisterPageState();
}

class _LoginRegisterPageState extends State<LoginRegisterPage> {
  @override
  void initState() {
    super.initState();
    _checkIfUserIsLoggedIn();
  }

  Future<void> _checkIfUserIsLoggedIn() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        bool hasRecognized = userDoc['hasRecognized'] ?? false;

        if (!mounted) return;
        if (hasRecognized) {
          Navigator.pushReplacementNamed(context, '/user-recognition-1');
        } else {
          Navigator.pushReplacementNamed(context, '/user-recognition');
        }
      } else {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/user-recognition');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            if (!mounted) return;
            Navigator.pushReplacementNamed(context, '/home');
          },
          child: const Text('Log In'),
        ),
      ),
    );
  }
}
