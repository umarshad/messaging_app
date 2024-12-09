import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:messaging_app/components/constants/colors.dart';
import 'package:messaging_app/components/constants/images.dart';
import 'package:messaging_app/components/customs/custom_button.dart';
import 'package:messaging_app/views/auth/login_screen.dart';
import 'package:messaging_app/views/screens/chat_screen.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final TextEditingController _searchController = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: AppColors.blueColor,
        title: const Text(
          'Add Contacts',
          style: TextStyle(color: AppColors.whiteColor),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              auth.signOut().then((value) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()));
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Logged Out Successfully")));
              }).onError((error, stackTrace) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${error.toString()}'),
                  ),
                );
              });
            },
            color: AppColors.whiteColor,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Add people who are already using the app or\n invite people to join',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final currentUserId = auth.currentUser?.uid;
                  final users = snapshot.data!.docs.where((user) {
                    final userId = user.id;
                    final name = user['name'].toString().toLowerCase();
                    final query = _searchController.text.toLowerCase();
                    return userId != currentUserId && name.contains(query);
                  }).toList();

                  if (users.isEmpty) {
                    return const Center(
                      child: Text('No contacts found'),
                    );
                  }

                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                              leading: const CircleAvatar(
                                backgroundImage:
                                    AssetImage(AppImages.profileImg),
                              ),
                              title: Text(user['name']),
                              subtitle: Text(user['email']),
                              trailing: SizedBox(
                                width: 100,
                                child: CustomButton(
                                  bgColor: AppColors.blueColor,
                                  onTap: () {
                                    // Navigate to ChatScreen
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatScreen(
                                          targetUserId: user.id,
                                          targetUserName: user['name'],
                                        ),
                                      ),
                                    );
                                  },
                                  text: "Message",
                                ),
                              )),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            CustomButton(
                bgColor: AppColors.blueColor, onTap: () {}, text: "Continue"),
          ],
        ),
      ),
    );
  }
}
