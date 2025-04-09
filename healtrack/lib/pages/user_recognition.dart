import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Status bar kontrolü için
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healtrack/pages/user_recognition_1.dart';
import 'package:healtrack/pages/login_register_page.dart';

class UserRecognition extends StatefulWidget {
  const UserRecognition({super.key});

  @override
  State<UserRecognition> createState() => _UserRecognitionState();
}

class _UserRecognitionState extends State<UserRecognition> {
  final List<String> goals = [
    'Eating healthier',
    'Lose weight',
    'Gain weight',
    'Increasing muscle mass'
  ];

  final Set<String> selectedGoals = {};

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    checkIfUserHasGoals();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  Future<void> checkIfUserHasGoals() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginRegisterPage()),
        );
      }
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('userProfiles')
          .where('userId', isEqualTo: user.uid)
          .get();

      if (snapshot.docs.isNotEmpty) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => UserRecognition1()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
    }
  }

  void sendToFirebase() async {
    if (selectedGoals.isNotEmpty) {
      try {
        final user = FirebaseAuth.instance.currentUser;

        if (user == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please log in first.')),
            );
          }
          return;
        }

        await FirebaseFirestore.instance.collection('userProfiles').add({
          'goals': selectedGoals.toList(),
          'timestamp': FieldValue.serverTimestamp(),
          'userId': user.uid,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Goals successfully saved!')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => UserRecognition1()),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('An error occurred: $e')),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select at least one goal.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          // İçerik
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Geri butonu
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      if (mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginRegisterPage()),
                        );
                      }
                    },
                  ),
                ),
                SizedBox(height: 16),
                // Soru
                Text(
                  'Which of the following goals would you like to achieve in the field of nutrition?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 32),
                // Kartlar
                Expanded(
                  child: ListView.builder(
                    itemCount: goals.length,
                    itemBuilder: (context, index) {
                      final goal = goals[index];
                      final isSelected = selectedGoals.contains(goal);

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                selectedGoals.remove(goal);
                              } else {
                                selectedGoals.add(goal);
                              }
                            });
                          },
                          child: Card(
                            color:
                                isSelected ? Colors.greenAccent : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Center(
                                child: Text(
                                  goal,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: FloatingActionButton(
                      onPressed: sendToFirebase,
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
