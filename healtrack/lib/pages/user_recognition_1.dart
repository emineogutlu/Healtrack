import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:healtrack/pages/user_recognition.dart';
import 'package:healtrack/pages/user_recognition_2.dart';

class UserRecognition1 extends StatefulWidget {
  const UserRecognition1({super.key});

  @override
  State<UserRecognition1> createState() => _UserRecognition1State();
}

class _UserRecognition1State extends State<UserRecognition1> {
  final TextEditingController _goalController = TextEditingController();
  final TextEditingController _nameController =
      TextEditingController(); // Kullanıcı adı için controller
  final bool _goalSaved = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    _checkIfUserAlreadySavedGoal();
  }

  @override
  void dispose() {
    _goalController.dispose();
    _nameController.dispose(); // Controller'ı temizle
    super.dispose();
  }

  Future<void> _checkIfUserAlreadySavedGoal() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        DocumentSnapshot userGoalDoc = await FirebaseFirestore.instance
            .collection('userProfiles')
            .doc(user.uid)
            .get();

        if (userGoalDoc.exists) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => UserRecognition2()),
          );
        }
      } catch (e) {
        print('Error checking user goal: $e');
      }
    }
  }

  void sendGoalAndNameToFirebase() async {
    final goal = _goalController.text.trim();
    final name = _nameController.text.trim();

    if (goal.isNotEmpty && name.isNotEmpty) {
      try {
        final user = FirebaseAuth.instance.currentUser;

        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please log in first.')),
          );
          return;
        }

        await FirebaseFirestore.instance
            .collection('userProfiles')
            .doc(user.uid)
            .set({
          'name': name,
          'goal': goal,
          'userId': user.uid,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Goal and Name successfully saved!')),
        );
        Navigator.pushReplacementNamed(context, '/user-recognition-2');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter both your goal and name.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_goalSaved) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UserRecognition2()),
      );
    }
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/assets/images/header.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserRecognition(),
                          ),
                        );
                      }),
                ),
                Text(
                  'What is your name?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Enter your name',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'What is your primary nutrition goal?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _goalController,
                  decoration: InputDecoration(
                    labelText: 'Enter your goal here',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: FloatingActionButton(
                      onPressed: () {
                        sendGoalAndNameToFirebase();
                      },
                      child: Icon(Icons.arrow_forward),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
