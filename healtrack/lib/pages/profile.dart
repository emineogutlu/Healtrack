import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  final String userId;
  const ProfilePage({super.key, required this.userId});

  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? userName;
  int? height;
  int? weight;
  String? userGoals;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? currentUser = _auth.currentUser;

    if (currentUser != null) {
      try {
        DocumentSnapshot userDoc = await _firestore
            .collection('userProfiles')
            .doc(currentUser.uid)
            .get();

        DocumentSnapshot bodysDoc = await _firestore
            .collection('bodyMeasurements')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists && bodysDoc.exists) {
          setState(() {
            userName = userDoc['name'] ?? 'No Name Set';
            height = bodysDoc['height'] != null
                ? int.tryParse(bodysDoc['height'].toString())
                : null;
            weight = bodysDoc['weight'] != null
                ? int.tryParse(bodysDoc['weight'].toString())
                : null;
            userGoals = userDoc['goal'] ?? 'No Goals Set';
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          print('User data or goals not found');
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        print('Error loading user data: $e');
      }
    }
  }

  Future<void> _updateUserData(
      String field, String value, String collection) async {
    User? currentUser = _auth.currentUser;

    if (currentUser != null) {
      try {
        await _firestore.collection(collection).doc(currentUser.uid).set(
            {field: value},
            SetOptions(
                merge: true)); // (eklenmek istenen veri,mevcut veriyi koruma)

        setState(() {
          if (field == 'name') {
            userName = value;
          } else if (field == 'goal') {
            userGoals = value;
          } else if (field == 'height') {
            height = int.tryParse(value);
          } else if (field == 'weight') {
            weight = int.tryParse(value);
          }
        });
      } catch (e) {
        print('Error updating user data: $e');
      }
    }
  }

  void _showUpdateDialog(String field, String currentValue, String collection) {
    TextEditingController controller =
        TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update $field'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'Enter new value'),
          keyboardType: TextInputType.text,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _updateUserData(field, controller.text, collection);
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/images/header.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildProfileBlock(
                        'Username:',
                        userName ?? 'No Name',
                        () => _showUpdateDialog(
                            'name', userName ?? '', 'userProfiles'),
                      ),
                      _buildProfileBlock(
                        'Body Measurements:',
                        'Height: ${height != null ? '$height cm' : 'N/A'}, Weight: ${weight != null ? '$weight kg' : 'N/A'}',
                        null,
                        showHeightButton: true,
                        showWeightButton: true,
                      ),
                      _buildProfileBlock(
                        'Your Goals:',
                        userGoals ?? 'No Goals Set',
                        () => _showUpdateDialog(
                            'goal', userGoals ?? '', 'userProfiles'),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildProfileBlock(String title, String content, VoidCallback? onEdit,
      {bool showHeightButton = false, bool showWeightButton = false}) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.all(8),
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10),
          if (onEdit != null)
            ElevatedButton(
              onPressed: onEdit,
              child: Text('Update'),
            ),
          if (showHeightButton)
            ElevatedButton(
              onPressed: () {
                _showUpdateDialog(
                    'height', height?.toString() ?? '', 'bodyMeasurements');
              },
              child: Text('Update Height'),
            ),
          if (showWeightButton)
            ElevatedButton(
              onPressed: () {
                _showUpdateDialog(
                    'weight', weight?.toString() ?? '', 'bodyMeasurements');
              },
              child: Text('Update Weight'),
            ),
        ],
      ),
    );
  }
}
