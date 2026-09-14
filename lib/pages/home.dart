import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
import 'package:flutter_compass/flutter_compass.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  String? _mapStyle;
  Position? currentPosition;
final MapController _mapController = MapController();
double heading = 0;
@override
void initState() {
  super.initState();
  _loadMapStyle();
  _getCurrentLocation();

  FlutterCompass.events?.listen((event) {
    setState(() {
      heading = event.heading ?? 0;
    });
  });
}

  Future<void> _loadMapStyle() async {
    final style = await rootBundle.loadString('assets/maps_style.json');
    setState(() {
      _mapStyle = style;
    });
  }
  Future<void> _getCurrentLocation() async {
  bool serviceEnabled =
      await Geolocator.isLocationServiceEnabled();

  if (!serviceEnabled) return;

  LocationPermission permission =
      await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  Position position =
      await Geolocator.getCurrentPosition();

  setState(() {
    currentPosition = position;
  });

  _mapController.move(
    LatLng(position.latitude, position.longitude),
    18,
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(17.55050987776072, 78.16571381374303),
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key=VrCsVifiD5AlRIjpOO40',
                userAgentPackageName: 'com.example.project_1',
              ),
              if (currentPosition != null)
  MarkerLayer(
    markers: [
  Marker(
  point: LatLng(
    currentPosition!.latitude,
    currentPosition!.longitude,
  ),
  width: 50,
  height: 50,
  child: Stack(
    alignment: Alignment.center,
    children: [
      Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
      ),
      Container(
        width: 25,
        height: 25,
        decoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 3,
          ),
        ),
      ),
    ],
  ),
),
    ],
  ),
            ],
          ),
          Positioned(top: 16, left: 16, right: 16, child: _searchField()),
        ],
      ), // Stack
    );
  }
  
  Container _searchField() {
    return Container(
      // margin: const EdgeInsets.only(left: 40, right: 20, top: 20),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0xff1D1617).withOpacity(0.11),
            spreadRadius: 0.0,
            blurRadius: 40,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 20,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(5),
            child: SvgPicture.asset(
              'assets/icons/search.svg',
              width: 12,
              height: 12,
              color: Colors.grey,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          hintText: 'Search the Destination',
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(5),
          bottomRight: Radius.circular(5),
        ),
      ),
      title: const Text(
        'GITAM Maps',
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

