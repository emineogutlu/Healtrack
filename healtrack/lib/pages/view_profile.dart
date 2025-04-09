import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healtrack/pages/choosing_a_dietitian.dart';
import 'package:healtrack/pages/make%20_an_appointment.dart';

class ViewProfile extends StatelessWidget {
  final String dietitianId;

  const ViewProfile({super.key, required this.dietitianId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('dietitians')
            .doc(dietitianId)
            .get(), // Diyetisyen bilgilerini alıyoruz
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text(
                "Dietitian information not found.",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final dietitianData = snapshot.data!.data() as Map<String, dynamic>;

          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    "lib/assets/images/header.jpg"), // Arka plan resminiz
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChoosingADietitian(),
                        ),
                      );
                    },
                  ),

                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: dietitianData['profileImage'] != null
                            ? NetworkImage(dietitianData['profileImage'])
                            : null,
                        child: dietitianData['profileImage'] == null
                            ? Icon(Icons.person, size: 50)
                            : null,
                      ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dietitianData['name'] ?? "Unknown",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Dietitian",
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  Text(
                    "Education",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Master Degree: ${dietitianData['masterDegree'] ?? '-'}",
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    "Bachelor Degree: ${dietitianData['bachelorDegree'] ?? '-'}",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 24),
                  // Uzmanlık alanları
                  Text(
                    "Areas of Expertise",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  if (dietitianData['specialties'] != null &&
                      (dietitianData['specialties'] as List<dynamic>)
                          .isNotEmpty)
                    ...List<Widget>.from(
                      (dietitianData['specialties'] as List<dynamic>).map(
                        (specialty) => Text(
                          "• $specialty",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    )
                  else
                    Text(
                      "No areas of expertise found.",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  SizedBox(height: 24),

                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Diyetisyen bilgilerini MakeAppointmentPage'e gönderiyoruz
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MakeAppointmentPage(
                              dietitianId: dietitianId,
                              dietitianName: dietitianData['name'],
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                      child: Text("Make an Appointment"),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
