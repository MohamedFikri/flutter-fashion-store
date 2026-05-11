import 'package:flutter/material.dart';

class HomeScreenWorking extends StatefulWidget {
  const HomeScreenWorking({super.key});

  @override
  State<HomeScreenWorking> createState() => _HomeScreenWorkingState();
}

class _HomeScreenWorkingState extends State<HomeScreenWorking> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ModaFusion'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'Firebase Products Working',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
