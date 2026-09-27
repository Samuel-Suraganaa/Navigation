import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Map'),
      ),
      body: const Center(
        child: Text('Map Page'),
      ),
    );
  }
}