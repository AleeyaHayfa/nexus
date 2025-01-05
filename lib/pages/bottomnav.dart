import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:nexusgo/pages/order.dart';
import 'package:nexusgo/pages/profile.dart';
import 'package:nexusgo/pages/wallet.dart';

import 'home.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int currentTabIndex = 0;

  late List<Widget> pages;
  late Widget currentPage;
  late Home homepage;
  late Profile profile;
  late Order order;
  late Wallet wallet;

  @override
  void initState() {
    homepage = const Home();
    order = const Order();
    profile = const Profile();
    wallet = const Wallet();
    pages = [homepage, refrigerator, recipegen, profile];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        height: 65,
        backgroundColor: Colors.white,
        color: Colors.black,
        animationDuration: const Duration(milliseconds: 500),
        onTap: (int index){
          setState(() {
            currentTabIndex = index;
          });
        },
        items: const [
        Icon(
          Icons.home_outlined, //homepage
          color: Colors.white,
        ),
        Icon(
          Icons.food_bank_outlined, //Food organization
          color: Colors.white,
        ),
        Icon(
          Icons.wallet_outlined, //Recipe Generator
          color: Colors.white,
        ),
        Icon(
          Icons.person_outline, //Profile
          color: Colors.white,
        )
      ]),
      body: pages[currentTabIndex],
    );
  }
}
