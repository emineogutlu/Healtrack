import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healtrack/pages/home_page.dart';

class MakeAppointmentPage extends StatefulWidget {
  final String dietitianId;
  final String dietitianName;

  const MakeAppointmentPage({
    super.key,
    required this.dietitianId,
    required this.dietitianName,
  });

  @override
  State<MakeAppointmentPage> createState() => _MakeAppointmentPageState();
}

class _MakeAppointmentPageState extends State<MakeAppointmentPage> {
  String? selectedTime;

  Future<void> _saveAppointment() async {
    if (selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time.')),
      );
      return;
    }

    try {
      // Kullanıcı bilgileri
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in.')),
        );
        return;
      }

      // Randevu verilerini Firestore'a kaydetme
      await FirebaseFirestore.instance.collection('appointments').add({
        'userId': user.uid,
        'dietitianId': widget.dietitianId,
        'dietitianName': widget.dietitianName,
        'appointmentTime': selectedTime,
        'appointmentDate': DateTime.now(),
        'status': 'pending',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Your appointment has been confirmed: $selectedTime')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.dietitianName} Appointment with'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/images/header.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Select a time:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              RadioListTile(
                title: const Text('10:00 - 10:15'),
                value: '10:00 - 10:15',
                groupValue: selectedTime,
                onChanged: (value) {
                  setState(() {
                    selectedTime = value.toString();
                  });
                },
              ),
              RadioListTile(
                title: const Text('10:30 - 10:45'),
                value: '10:30 - 10:45',
                groupValue: selectedTime,
                onChanged: (value) {
                  setState(() {
                    selectedTime = value.toString();
                  });
                },
              ),
              RadioListTile(
                title: const Text('11:00 - 11:15'),
                value: '11:00 - 11:15',
                groupValue: selectedTime,
                onChanged: (value) {
                  setState(() {
                    selectedTime = value.toString();
                  });
                },
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    await _saveAppointment();
                  },
                  child: const Text('Confirm Appointment'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
