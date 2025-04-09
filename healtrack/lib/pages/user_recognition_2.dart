import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healtrack/pages/home_page.dart';
import 'package:healtrack/pages/user_recognition_1.dart';
import 'package:flutter/services.dart';

class UserRecognition2 extends StatefulWidget {
  const UserRecognition2({super.key});

  @override
  State<UserRecognition2> createState() => _UserRecognization2State();
}

class _UserRecognization2State extends State<UserRecognition2> {
  String? selectedHeight;
  String? selectedWeight;
  final List<String> heights =
      List.generate(41, (index) => (150 + index).toString()); // 150 cm - 190 cm
  final List<String> weights =
      List.generate(61, (index) => (50 + index).toString()); // 50 kg - 110 kg

  Future<void> _checkIfUserDataExists() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('bodyMeasurements')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    _checkIfUserDataExists();
  }

  void saveDataToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && selectedHeight != null && selectedWeight != null) {
      try {
        await FirebaseFirestore.instance
            .collection('bodyMeasurements')
            .doc(user.uid)
            .set({
          'height': selectedHeight,
          'weight': selectedWeight,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data has been successfully saved!')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
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
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 70.0,
              horizontal: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Please fill in.',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 25),
                DropdownButtonFormField<String>(
                  value: selectedHeight,
                  items: heights.map((height) {
                    return DropdownMenuItem(
                      value: height,
                      child: Text('$height cm'),
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    labelText: 'Your height (cm)',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() {
                      selectedHeight = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: selectedWeight,
                  items: weights.map((weight) {
                    return DropdownMenuItem(
                      value: weight,
                      child: Text('$weight kg'),
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    labelText: ' Body weight (kg)',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() {
                      selectedWeight = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                const Text('Upload your blood tests to the screen.'),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(3, (index) {
                    return ElevatedButton(
                      onPressed: () {},
                      child: const Icon(Icons.add_a_photo),
                    );
                  }),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserRecognition1(),
                          ),
                        );
                      },
                      child: const Icon(Icons.arrow_back),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (selectedHeight != null && selectedWeight != null) {
                          saveDataToFirebase();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Please select your height and weight.'),
                            ),
                          );
                        }
                      },
                      child: const Icon(Icons.arrow_forward),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
