import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nexusgo/service/database.dart';  // Import your DatabaseMethods class
import 'package:firebase_auth/firebase_auth.dart';  // Import FirebaseAuth to get userId

class Fridge extends StatefulWidget {
  const Fridge({Key? key}) : super(key: key);

  @override
  State<Fridge> createState() => _FridgeState();
}

class _FridgeState extends State<Fridge> {
  final DatabaseMethods _databaseMethods = DatabaseMethods();  // Initialize DatabaseMethods instance
  late Stream<QuerySnapshot> fridgeStream;
  String searchQuery = "";
  String userId = "";  // Variable to hold userId
  String userName = "";  // Variable to hold userName


  void _getUserInfo() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users') // Replace 'users' with your Firestore user collection name
          .doc(userId)
          .get();

      if (userDoc.exists) {
        setState(() {
          userId = user.uid; // Get userId
          userName = userDoc.data()?['Name'] ?? 'Unknown User'; // Get userName from Firestore
        });
      } else {
        print("User document does not exist in Firestore.");
      }
    } catch (e) {
      print("Error fetching user info from Firestore: $e");
    }
  }
}

@override
  void initState() {
    super.initState();

    // Get current user information
    _getUserInfo();

    fridgeStream = FirebaseFirestore.instance.collection('Fridge').snapshots();  // Replace this with your custom method if needed
  }
  Future<void> addFood(
      String name, String category, DateTime expiredDate, int quantity) async {
    if (userId.isNotEmpty && userName.isNotEmpty) {
      final fridge = {
        'name': name,
        'category': category,
        'date': DateTime.now().toIso8601String(),
        'expiredDate': expiredDate.toIso8601String(),
        'quantity': quantity,
        'completed': false,
      };

      // Pass userId and userName when calling the method to add food item
      await _databaseMethods.addFoodItem(fridge, userId, userName);
    }
  }

  Future<void> deleteFood(String id) async {
    await FirebaseFirestore.instance.collection('fridge').doc(id).delete();
  }

  void createNewFoodItem() {
  final nameController = TextEditingController();
  final quantityController = TextEditingController();
  String selectedCategory = "Freezer";
  DateTime selectedDate = DateTime.now();

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Add New Food'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Food Name'),
                ),
                TextField(
                  controller: quantityController,
                  decoration: InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                ),
                DropdownButton<String>(
                  value: selectedCategory,
                  items: const [
                    DropdownMenuItem(value: "Freezer", child: Text("Freezer")),
                    DropdownMenuItem(value: "Chiller", child: Text("Chiller")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                    });
                  },
                ),
                ElevatedButton(
                  onPressed: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        selectedDate = pickedDate;
                      });
                    }
                  },
                  child: Text(
                      'Select Expired Date: ${selectedDate.toLocal().toString().split(' ')[0]}'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  final quantity =
                      int.tryParse(quantityController.text.trim()) ?? 0;
                  if (name.isNotEmpty && quantity > 0) {
                    addFood(name, selectedCategory, selectedDate, quantity);
                  }
                  Navigator.pop(context);
                },
                child: Text('Add'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
            ],
          );
        },
      );
    },
  );
}


  List<QueryDocumentSnapshot> filterFridges(List<QueryDocumentSnapshot> fridges) {
    return fridges.where((fridge) {
      final data = fridge.data() as Map<String, dynamic>;
      final name = data['name']?.toString().toLowerCase() ?? "";
      return name.contains(searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Inventory'),
        actions: [
          IconButton(
            onPressed: createNewFoodItem,
            icon: const Icon(Icons.add),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search food...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: fridgeStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final fridges = filterFridges(snapshot.data!.docs);

          final upperFridges = fridges
              .where((fridge) =>
                  (fridge.data() as Map<String, dynamic>)['category'] == 'Upper')
              .toList();
          final lowerFridges = fridges
              .where((fridge) =>
                  (fridge.data() as Map<String, dynamic>)['category'] == 'Lower')
              .toList();

          return ListView(
            children: [
              if (upperFridges.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Freezer',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                ...upperFridges.map((fridge) => buildFridgeTile(fridge)).toList(),
              ],
              if (lowerFridges.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Chiller',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                ...lowerFridges.map((fridge) => buildFridgeTile(fridge)).toList(),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget buildFridgeTile(QueryDocumentSnapshot fridge) {
    final data = fridge.data() as Map<String, dynamic>;
    final id = fridge.id;

    return ListTile(
      title: Text(data['name'] ?? 'Unnamed Food'),
      subtitle: Text(
          'Category: ${data['category'] ?? 'Uncategorized'}\nExpired Date: ${data['expiredDate'] ?? 'No Expiry'}\nQuantity: ${data['quantity'] ?? 0}'),
      trailing: IconButton(
        icon: Icon(Icons.delete, color: Colors.red),
        onPressed: () => deleteFood(id),
      ),
    );
  }
}
