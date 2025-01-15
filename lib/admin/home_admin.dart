import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nexusgo/admin/add_food.dart';
import 'package:nexusgo/admin/admin_login.dart';
import 'package:nexusgo/admin/announcement.dart';
import 'package:nexusgo/widget/widget_support.dart';

class HomeAdmin extends StatefulWidget {
  const HomeAdmin({super.key});

  @override
  State<HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  Stream<QuerySnapshot>? feedbackStream, listUserStream;
   String? name, email;

  @override
  void initState() {
    super.initState();
    // Initialize feedbackStream with data from Firestore
    feedbackStream = FirebaseFirestore.instance.collection('feedbacks').snapshots();
    listUserStream = FirebaseFirestore.instance.collection('users').snapshots();
  }

Widget listUser(Stream listUserStream) {
  return StreamBuilder(
    stream: listUserStream,
    builder: (context, AsyncSnapshot snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }

      if (snapshot.data.docs.isEmpty) {
        return const Center(
          child: Text(
            "No list user available.",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(10.0),
        itemCount: snapshot.data.docs.length,
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          DocumentSnapshot ds = snapshot.data.docs[index];

          // Extract and validate data
          String name = ds["Name"] ?? "No Title";
          String email = ds["Email"] ?? "No Description";

          return Container(
            margin: const EdgeInsets.only(bottom: 10.0),
            child: Material(
              elevation: 5.0,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.orange[100],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 20.0),
                    // Title and Description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 5.0),
                          Text(
                            email,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    body: SingleChildScrollView(  // Added SingleChildScrollView for scrolling
      child: Container(
        margin: const EdgeInsets.only(top: 30.0, left: 20.0, right: 20.0),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(left: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AdminLogin()),
                    );
                  },
                        child: Container(
                          margin: const EdgeInsets.only(right: 20.0),
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.logout,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30.0), // Add spacing between the new section and the next section

            // Existing "Home Admin" section
            Center(
              child: Text(
                "Home Admin", 
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), // Replace with AppWidget.HeadlineTextFieldStyle() if you have it defined
              ),
            ),
            const SizedBox(height: 40.0),
            
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddAnnouncement()),
                );
              },
              child: Material(
                elevation: 10.0,
                borderRadius: BorderRadius.circular(10),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Image.asset(
                            "images/salad2.png", 
                            height: 100, 
                            width: 100, 
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 30.0),
                        const Text(
                          "Add Announcement", 
                          style: TextStyle(
                            color: Colors.white, 
                            fontSize: 20.0, 
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50.0),
            
            // Existing List of User section
            Text("List of User", style: AppWidget.HeadlineTextFieldStyle(),),
            listUser(listUserStream!),
            const SizedBox(height: 10.0),
            
            // Feedback Stream Section
            Text("Feedback", style: AppWidget.HeadlineTextFieldStyle(),),
            feedbackStream != null
                ? StreamBuilder<QuerySnapshot>(
                    stream: feedbackStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No feedbacks available.'));
                      }

                      // Extract and display the feedbacks
                      final feedbacks = snapshot.data!.docs;
                      return ListView.builder(
                        shrinkWrap: true,  // Allow ListView to be scrollable within Column
                        itemCount: feedbacks.length,
                        itemBuilder: (context, index) {
                          final feedback = feedbacks[index];
                          final email = feedback['email'];
                          final description = feedback['description'];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 10.0),
                            child: ListTile(
                              title: Text(email),
                              subtitle: Text(description),
                              trailing: Icon(Icons.report),
                            ),
                          );
                        },
                      );
                    },
                  )
                : const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    ),
  );
}


}
