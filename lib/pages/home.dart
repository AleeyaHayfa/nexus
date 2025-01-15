import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:nexusgo/pages/details.dart';
import 'package:nexusgo/service/database.dart';
// import 'package:nexusgo/service/auth.dart';
import 'package:nexusgo/widget/widget_support.dart';
import 'package:nexusgo/service/shared_pref.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
   String? profile, name, email;
  final List<Map<String, dynamic>> communityPosts = [];
  final TextEditingController postController = TextEditingController();
  final TextEditingController commentController = TextEditingController();
  final Map<String, TextEditingController> commentControllers = {};

  // Ensure to dispose controllers to avoid memory leaks
  @override
  void dispose() {
    commentControllers.forEach((key, controller) {
      controller.dispose();
    });
    super.dispose();
  }
   // New controller for comments
   

  void addPost(String content) {
    setState(() {
      communityPosts.add({'content': content, 'comments': []});
    });
    postController.clear();
  }

  void addComment(int postIndex, String comment) {
    setState(() {
      communityPosts[postIndex]['comments'].add(comment);
    });
    commentController.clear(); // Clear the comment input field after adding a comment
  }
  Stream? announcementStream;
  
  @override
  void initState() {
    
    super.initState();
    ontheload();
  }

  getthesharedpref() async {
    profile = await SharedPreferenceHelper().getUserProfile();
    name = await SharedPreferenceHelper().getUserName();
    email = await SharedPreferenceHelper().getUserEmail();
    setState(() {});
  }

  ontheload() async {
  announcementStream = await DatabaseMethods().getAnnouncement("AnnounceItems");
  setState(() {});
}

  Widget showAnnouncement(Stream announcementStream) {
  return StreamBuilder(
    stream: announcementStream,
    builder: (context, AsyncSnapshot snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }

      if (snapshot.data.docs.isEmpty) {
        return const Center(
          child: Text(
            "No announcements available.",
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
          String imageUrl = ds["Image"] ?? "";
          String title = ds["Title"] ?? "No Title";
          String description = ds["Detail"] ?? "No Description";

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
                    // Image Display
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              height: 120,
                              width: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image, size: 120),
                            )
                          : const Icon(
                              Icons.image_not_supported,
                              size: 120,
                              color: Colors.grey,
                            ),
                    ),
                    const SizedBox(width: 20.0),
                    // Title and Description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 5.0),
                          Text(
                            description,
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



  Widget showFoodManagement() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Food Management Header
        Text("User Food Management", style: AppWidget.boldTextFieldStyle()),
        const SizedBox(height: 10),
        Row(
          children: [
            // Add Food Button
            ElevatedButton(
              onPressed: () {
                // Implement food addition logic here
              },
              child: Text("Add Food"),
            ),
            const SizedBox(width: 10),
            // Delete Food Button
            ElevatedButton(
              onPressed: () {
                // Implement food deletion logic here
              },
              child: Text("Delete Food"),
            ),
          ],
        ),
      ],
    );
  }

  Widget showFoodAlerts() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text("Food Alerts", style: AppWidget.boldTextFieldStyle()),
      const SizedBox(height: 10),
      // Food Alert styled like food menu items
      Container(
        margin: const EdgeInsets.only(bottom: 10, right: 20.0),
        child: Material(
          elevation: 5.0,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.red[100],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    color: Colors.red[300],
                    padding: const EdgeInsets.all(5),
                    child: Icon(Icons.warning, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Pizza is nearing expiration", 
                        style: AppWidget.semiBoldTextFieldStyle()),
                    const SizedBox(height: 5.0),
                    Text("Expires in 2 days", 
                        style: AppWidget.LightTextFieldStyle()),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}


  Widget showHighRiskFoods() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text("High-Risk Foods", style: AppWidget.boldTextFieldStyle()),
      const SizedBox(height: 10),
      // High-Risk Food styled like food menu items
      Container(
        margin: const EdgeInsets.only(bottom: 10, right: 20.0),
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
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    color: Colors.orange[300],
                    padding: const EdgeInsets.all(5),
                    child: Icon(Icons.warning_amber_outlined, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Rice is at risk of spoiling soon", 
                        style: AppWidget.semiBoldTextFieldStyle()),
                    const SizedBox(height: 5.0),
                    Text("Check storage conditions", 
                        style: AppWidget.LightTextFieldStyle()),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}



  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      title: Text(
        "Hello",
        style: AppWidget.HeadlineTextFieldStyle(),
      ),
    ),
    body: SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.only(top: 5.0, left: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              // children: [
              //   Text(
              //     "Hello,",
              //     style: AppWidget.boldTextFieldStyle(),
              //   ),
              // ],
            ),
            const SizedBox(height: 30.0),
            // Announcement Stream
            Text("Announcement", style: AppWidget.boldTextFieldStyle()),
            announcementStream != null
                ? showAnnouncement(announcementStream!)
                : const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 20.0),
            showFoodAlerts(),
            const SizedBox(height: 30.0),
            showHighRiskFoods(),
            const SizedBox(height: 30.0),
            Text(
              "Community Posts",
              style: AppWidget.HeadlineTextFieldStyle(),
            ),
            const SizedBox(height: 10.0),
            TextField(
              controller: postController,
              decoration: InputDecoration(
                hintText: "Write a post...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    if (postController.text.trim().isNotEmpty) {
                      final userId = await SharedPreferenceHelper().getUserId();
                      final userName =
                          await SharedPreferenceHelper().getUserName();
                      if (userId != null && userName != null) {
                        await DatabaseMethods().addPost(
                          {
                            'content': postController.text.trim(),
                            'userName': userName,
                            'userId': userId,
                          },
                          userId,
                        );
                        setState(() {
                          postController.clear();
                        });
                      }
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            // Community Posts Section
            FutureBuilder<String?>(
              future: SharedPreferenceHelper().getUserId(),
              builder: (context, userIdSnapshot) {
                if (!userIdSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final userId = userIdSnapshot.data!;
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .collection('Post')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final posts = snapshot.data!.docs;
                    if (posts.isEmpty) {
                      return const Text("No posts available");
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        final postId = post.id;

                        if (!commentControllers.containsKey(postId)) {
                          commentControllers[postId] = TextEditingController();
                        }

                        final commentController = commentControllers[postId]!;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '${post['userName']}\n',
                                        style: AppWidget.LightTextFieldStyle(),
                                      ),
                                      TextSpan(
                                        text: post['content'],
                                        style: AppWidget.semiBoldTextFieldStyle(),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10.0),
                                TextField(
                                  controller: commentController,
                                  decoration: InputDecoration(
                                    hintText: "Add a comment...",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: const Icon(Icons.comment),
                                      onPressed: () async {
                                        if (commentController.text
                                            .trim()
                                            .isNotEmpty) {
                                          final userName =
                                              await SharedPreferenceHelper()
                                                  .getUserName();
                                          await DatabaseMethods().addComment(
                                            {
                                              'content': commentController
                                                  .text
                                                  .trim(),
                                              'userName': userName,
                                              'userId': userId,
                                            },
                                            userId,
                                            postId,
                                            userName!,
                                          );
                                          setState(() {
                                            commentController.clear();
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10.0),
                                StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(userId)
                                      .collection('Post')
                                      .doc(postId)
                                      .collection('Comments')
                                      .snapshots(),
                                  builder: (context, commentSnapshot) {
                                    if (!commentSnapshot.hasData) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    }
                                    final comments =
                                        commentSnapshot.data!.docs;
                                    if (comments.isEmpty) {
                                      return const Text("No comments yet");
                                    }
                                    return ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: comments.length,
                                      itemBuilder: (context, index) {
                                        final comment = comments[index];
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 5.0),
                                          child: Text(
                                            "${comment['userName']}: ${comment['content']}",
                                            style:
                                                AppWidget.LightTextFieldStyle(),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}
}
