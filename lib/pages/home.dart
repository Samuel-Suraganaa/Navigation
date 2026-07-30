import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: Column(
        children: [
          TextField(), // Add your widgets here
        ],
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      title: const Text(
        'GITAM 3D',
        style: TextStyle(
          color: Color.fromARGB(255, 0, 115, 103),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      elevation: 0.0,
      centerTitle: true,
      leading: GestureDetector(
        onTap: () {
          // Handle settings icon tap
        },
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: const Icon(
            Icons.menu,
            color: Color.fromARGB(255, 0, 115, 103),
          ),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () {
            // Handle settings icon tap
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            alignment: Alignment.center,
            width: 27,
            height: 37,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: SvgPicture.asset(
              'assets/icons/settings.svg',
              color: Color.fromARGB(255, 0, 115, 103),
            ),
          ),
        ),
      ],
    );
  }
}
