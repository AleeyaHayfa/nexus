import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nexusgo/pages/details.dart';
import 'package:nexusgo/service/database.dart';
import 'package:nexusgo/widget/widget_support.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool rice = false, vegetables = false, noodle = false, burger = false;
  final List<Map<String, dynamic>> communityPosts = [];
  final TextEditingController postController = TextEditingController();
  final TextEditingController commentController = TextEditingController(); // New controller for comments

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
  Stream? fooditemStream;

  @override
  void initState() {
    ontheload();
    super.initState();
  }

  ontheload() async {
    fooditemStream = await DatabaseMethods().getFoodItem("Pizza");
    setState(() {});
  }

  Widget allItemsVertically() {
    return StreamBuilder(
      stream: fooditemStream,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: snapshot.data.docs.length,
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Details(
                                  detail: ds["Detail"],
                                  name: ds["Name"],
                                  price: ds["Price"],
                                  image: ds["Image"])));
                    },
                    child: Container(
                      child: Column(
                        children: [
                          // Food Item Display (POST display)
                          Container(
                            margin: const EdgeInsets.only(right: 20.0, bottom: 10.0),
                            child: Material(
                              elevation: 5.0,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.network(
                                        ds["Image"],
                                        height: 120,
                                        width: 120,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 20.0),
                                    Column(
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context).size.width / 2,
                                          child: Text(ds["Name"], style: AppWidget.semiBoldTextFieldStyle()),
                                        ),
                                        const SizedBox(height: 5.0),
                                        SizedBox(
                                          width: MediaQuery.of(context).size.width / 2,
                                          child: Text("Honey goat cheese", style: AppWidget.LightTextFieldStyle()),
                                        ),
                                        const SizedBox(height: 5.0),
                                        SizedBox(
                                          width: MediaQuery.of(context).size.width / 2,
                                          child: Text("\$" + ds["Price"], style: AppWidget.semiBoldTextFieldStyle()),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
            : const CircularProgressIndicator();
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
        // Example of highlighting a food item nearing expiration
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.red[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              const SizedBox(width: 10),
              Text("Pizza is nearing expiration", style: AppWidget.LightTextFieldStyle()),
            ],
          ),
        ),
      ],
    );
  }

  Widget showAnalytics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Food Waste Analytics", style: AppWidget.boldTextFieldStyle()),
        const SizedBox(height: 10),
        Text("Monthly Food Waste Stats (Weight, Monetary Value)", style: AppWidget.LightTextFieldStyle()),
        // You can add Graphs/Charts here to show stats dynamically
        const SizedBox(height: 10),
        Text("Community Food Waste Data", style: AppWidget.LightTextFieldStyle()),
        // Show aggregated stats
      ],
    );
  }

  Widget showHighRiskFoods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("High-Risk Foods", style: AppWidget.boldTextFieldStyle()),
        const SizedBox(height: 10),
        // Example of a high-risk food item
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.orange[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(Icons.warning_amber_outlined, color: Colors.orange),
              const SizedBox(width: 10),
              Text("Rice is at risk of spoiling soon", style: AppWidget.LightTextFieldStyle()),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    body: SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.only(top: 50.0, left: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Hello Hayfa,", style: AppWidget.boldTextFieldStyle()),
                Container(
                  margin: const EdgeInsets.only(right: 20.0),
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.shopping_cart,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30.0),
            const SizedBox(height: 20.0),
            // Add the following method for adding posts
            showFoodManagement(), // Add/Delete food section
            const SizedBox(height: 30.0),
            showFoodAlerts(), // Alerts for food nearing expiration
            const SizedBox(height: 30.0),
            showAnalytics(), // Display stats
            const SizedBox(height: 30.0),
            showHighRiskFoods(), // Highlight foods at risk
            const SizedBox(height: 30.0),
            // Modify this section to include community post functionality
            // Container(
            //   height: 270,
            //   child: allItemsVertically(),
            // ),
            const SizedBox(height: 30.0),
            // Community Post Section
            Text("Community Posts", style: AppWidget.HeadlineTextFieldStyle()),
            const SizedBox(height: 10.0),
            TextField(
              controller: postController,
              decoration: InputDecoration(
                hintText: "Write a post...",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    if (postController.text.trim().isNotEmpty) {
                      await DatabaseMethods().addPost(
                        {'content': postController.text.trim(), 'comments': []},
                        'id', // Replace with actual user ID
                      );
                      setState(() {
                        postController.clear();
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc('id') // Replace with actual user ID
                  .collection('Post')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final posts = snapshot.data!.docs;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    final comments = post['comments'] ?? [];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(post['content'],
                                style: AppWidget.semiBoldTextFieldStyle()),
                            const SizedBox(height: 10.0),
                            TextField(
                              controller: commentController,
                              decoration: InputDecoration(
                                hintText: "Add a comment...",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0)),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.comment),
                                  onPressed: () async {
                                    if (commentController.text
                                        .trim()
                                        .isNotEmpty) {
                                      await DatabaseMethods().addPost(
                                        {'content': commentController.text.trim()},
                                        'user_id_here', // Replace with actual user ID
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
                            ...comments.map<Widget>((comment) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5.0),
                                child: Text("- $comment",
                                    style: AppWidget.LightTextFieldStyle()),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
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
