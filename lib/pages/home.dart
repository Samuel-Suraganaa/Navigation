import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _mapStyle;
  @override
  void initState() {
    super.initState();
    _loadMapStyle();
  }

  Future<void> _loadMapStyle() async {
    final style = await rootBundle.loadString('assets/maps_style.json');
    setState(() {
      _mapStyle = style;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _map(),
          Positioned(top: 16, left: 16, right: 16, child: _searchField()),
        ],
      ), // Stack
    );
  }

  Set<Marker> _buildMarkers() {
    return {
      Marker(
        markerId: const MarkerId('Central Park View'),
        position: const LatLng(17.550452582223073, 78.1657591399883),
        infoWindow: const InfoWindow(title: 'Central Park View'),
        onTap: () {
          // Handle marker tap
        },
      ),
      // Marker(
      //   markerId: const MarkerId('marker_2'),
      //   position: const LatLng(17.546114, 78.156991),
      //   infoWindow: const InfoWindow(title: 'Marker 2'),
      // ),
      // Marker(
      //   markerId: const MarkerId('marker_3'),
      //   position: const LatLng(17.552415, 78.168228),
      //   infoWindow: const InfoWindow(title: 'Marker 3'),
      // ),
    };
  }

  GoogleMap _map() {
    return GoogleMap(
      style: _mapStyle,
      initialCameraPosition: CameraPosition(
        target: LatLng(17.550618207669004, 78.165435851482),
        zoom: 18,
        bearing: 91,
      ),
      cameraTargetBounds: CameraTargetBounds(
        LatLngBounds(
          southwest: LatLng(17.546114, 78.156991),
          northeast: LatLng(17.552415, 78.168228),
        ),
      ),
      minMaxZoomPreference: const MinMaxZoomPreference(15, 20),
      zoomControlsEnabled: true, // enables zoom/unzoom buttons on the map
      zoomGesturesEnabled: true, // enables pinch-to-zoom gestures
      rotateGesturesEnabled: true, // or false, if you want to lock rotation
      markers: _buildMarkers(),
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
