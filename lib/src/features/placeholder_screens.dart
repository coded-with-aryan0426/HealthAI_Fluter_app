import 'package:flutter/material.dart';



class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Habits Tracker', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}



class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Profile & Settings', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
