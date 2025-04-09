import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healtrack/pages/choosing_a_dietitian.dart';
import 'package:healtrack/pages/profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Default olarak ana sayfa seçili olacak
  List<Map<String, dynamic>> appointments = [];
  String dailyInfo = '';
  User? user; // Kullanıcı bilgisi için değişken  User Firebase nesnesi

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
    _fetchDailyInfo();
  }

  // Firebase'den kullanıcı ID'sini alıyoruz
  void _fetchAppointments() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('userId', isEqualTo: user.uid)
          .get();

      setState(() {
        appointments = snapshot.docs
            .map((doc) => {
                  //Bir liste içindeki her öğeyi dönüştürmeye yararıyor
                  'id': doc.id, // randevunun ID'si
                  'dietitianName': doc['dietitianName'],
                  'appointmentTime': doc['appointmentTime'],
                  'status': doc['status'],
                })
            .toList();
      });
    }
  }

  void _fetchDailyInfo() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('daily').get();
      if (snapshot.docs.isNotEmpty) {
        final randomDoc = snapshot.docs[
            (snapshot.docs.length * DateTime.now().millisecond) %
                snapshot.docs.length];
        setState(() {
          dailyInfo = randomDoc['info'];
        });
      }
    } catch (e) {
      print("Error fetching daily info: $e");
      setState(() {
        dailyInfo = 'An error occurred while loading the daily information..';
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      HomePageContent(dailyInfo: dailyInfo), // dailyInfo burada aktarıldı
      Center(child: Text('Messages Page')),
      ProfilePage(
          userId: user?.uid ??
              ''), //user?.uid null dönerse, sağdaki değeri boş string kullanılacak
    ];
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/assets/images/header.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home Page',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomePageContent extends StatelessWidget {
  final String dailyInfo;
  const HomePageContent({super.key, required this.dailyInfo});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'HealTrack',
            style: TextStyle(
              fontSize: 35,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 4,
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(16.0),
            children: [
              CardContainer(
                cards: [
                  CardData(
                    title: 'My Appointments',
                    icon: Icons.calendar_today,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => AppointmentDetails(),
                      );
                    },
                  ),
                  CardData(
                    title: 'Make an appointment',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChoosingADietitian()),
                      );
                    },
                  ),
                  CardData(
                    title: 'A piece of information for each day.',
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        dailyInfo, 
                        style: TextStyle(fontSize: 16, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  CardData(
                    title: 'Your Advisory Team',
                    icon: Icons.group_add,
                    onTap: () {
                  
                      _showDietitianList(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Diyetisyen listesi gösterme fonksiyonu
void _showDietitianList(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) => DietitianList(),
  );
}

class DailyInfoBottomSheet extends StatelessWidget {
  final String dailyInfo;

  const DailyInfoBottomSheet({super.key, required this.dailyInfo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Today's Information",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            dailyInfo, 
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class DietitianList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchDietitianNames(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator()); // Yükleniyor göstergesi
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error.'));
        }

        final dietitianNames = snapshot.data ?? [];

        return ListView.builder(
          itemCount: dietitianNames.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(dietitianNames[index]), // Diyetisyen ismi
              onTap: () {
                print('Dietitian: ${dietitianNames[index]}');
              },
            );
          },
        );
      },
    );
  }

  // Diyetisyen isimlerini Firestore'dan almak
  Future<List<String>> _fetchDietitianNames() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('userId', isEqualTo: user.uid)
          .get();

      return snapshot.docs
          .map((doc) => doc['dietitianName'] as String)
          .toList();
    }
    return [];
  }
}

class CardContainer extends StatelessWidget {
  //Dinamik kart listesi
  final List<CardData> cards;

  const CardContainer({super.key, required this.cards});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: cards.map((card) => buildCard(context, card)).toList(),
    );
  }

  Widget buildCard(BuildContext context, CardData card) {
    return Card(
      color: Colors.white.withOpacity(0.8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading:
            card.icon != null ? Icon(card.icon, color: Colors.green) : null,
        title: Text(
          card.title,
          style: TextStyle(color: Colors.black),
        ),
        onTap: card.onTap,
        subtitle: card.child,
      ),
    );
  }
}

class CardData {
  final String title;
  final IconData? icon;
  final VoidCallback onTap; //Geri dönüş değeri olmayan bir fonksiyon
  final Widget? child;

  CardData({required this.title, this.icon, required this.onTap, this.child});
}

class AppointmentDetails extends StatefulWidget {
  @override
  State<AppointmentDetails> createState() => _AppointmentDetailsState();
}

class _AppointmentDetailsState extends State<AppointmentDetails> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchAppointments(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error.'));
        }

        final appointments = snapshot.data ?? [];

        return ListView.builder(
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(appointments[index]['dietitianName']),
              subtitle: Text('Time: ${appointments[index]['appointmentTime']}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(appointments[index]['status']),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await _cancelAppointment(appointments[index]['id']);
                      _fetchAppointments();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _fetchAppointments() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('userId', isEqualTo: user.uid)
          .get();

      return snapshot.docs
          .map((doc) => {
                'id': doc.id, // randevunun ID'si
                'dietitianName': doc['dietitianName'],
                'appointmentTime': doc['appointmentTime'],
                'status': doc['status'],
              })
          .toList();
    }
    return [];
  }

  Future<void> _cancelAppointment(String appointmentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointmentId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your appointment has been canceled.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
