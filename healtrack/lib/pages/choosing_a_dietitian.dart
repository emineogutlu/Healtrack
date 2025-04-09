import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healtrack/pages/view_profile.dart';

class ChoosingADietitian extends StatelessWidget {
  const ChoosingADietitian({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dietitians"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image:
                AssetImage('lib/assets/images/header.jpg'), // Arka plan resmi
            fit: BoxFit.cover,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          //snapshot veritabanında değişiklik olduğunda anlık güncellemeleri alır.
          stream:
              FirebaseFirestore.instance.collection('dietitians').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  "Dietitian not found.",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              );
            }

            final dietitians = snapshot.data!.docs;

            return ListView.builder(
              itemCount: dietitians.length, // Diyetisyen sayısı kadar Card
              itemBuilder: (context, index) {
                // Her bir diyetisyeni için
                final dietitian = dietitians[index];
                final dietitianId = dietitian.id; // Diyetisyen ID'sini aldık

                return Card(
                  color: Colors.white.withOpacity(0.8), // Şeffaflık için
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: Radio(
                      value: dietitianId,
                      groupValue: null, // Seçilen grup değeri
                      onChanged: (value) {},
                    ),
                    title: Text(dietitian['name']),
                    trailing: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewProfile(
                                dietitianId:
                                    dietitianId), // Diyetisyen ID'sini ViewProfile sayfasına gönderiyoruz
                          ),
                        );
                      },
                      child: Text("View Profile"),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
