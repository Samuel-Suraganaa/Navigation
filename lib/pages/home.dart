import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
import 'package:flutter_compass/flutter_compass.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:project_1/data/locations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

final TextEditingController _searchController =
    TextEditingController();
class _HomePageState extends State<HomePage> {
  String? _mapStyle;
  Position? currentPosition;

final MapController _mapController = MapController();
double heading = 0;
  List<LatLng> routePoints = [];

double distanceKm = 0;
double durationMin = 0;
Future<void> getRoute(
  double destLat,
  double destLng,
) async {

  final url =
      "https://api.openrouteservice.org/v2/directions/foot-walking";

  final response = await http.post(
    Uri.parse(url),
    headers: {
      "Authorization": "eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6IjQxYTJkOTQ3NDhmNTQ1MzViNjE2ZGQwMWNhNzE5MzEzIiwiaCI6Im11cm11cjY0In0=",
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "coordinates": [
        [
          currentPosition!.longitude,
          currentPosition!.latitude
        ],
        [78.16452268053641, 17.549902816477566],
        [
          destLng,
          destLat
        ]
      ]
    }),
  );

final data = jsonDecode(response.body);

if (data["routes"] == null || data["routes"].isEmpty) {
  print(response.body);
  return;
}

final geometry = data["routes"][0]["geometry"]; // this is an encoded polyline string

final polylinePoints = PolylinePoints();
final decoded = polylinePoints.decodePolyline(geometry);

routePoints = decoded
    .map((point) => LatLng(point.latitude, point.longitude))
    .toList();

distanceKm = data["routes"][0]["summary"]["distance"] / 1000;
durationMin = data["routes"][0]["summary"]["duration"] / 60;

  setState(() {});
}
Future<void> _searchLocation(String query) async {
  final result = locations.firstWhere(
    (location) =>
        location["name"]
            .toString()
            .toLowerCase() ==
        query.toLowerCase(),
    orElse: () => {},
  );
  

  if (result.isNotEmpty) {
    _mapController.move(
      LatLng(
        result["latitude"] as double,
        result["longitude"] as double,
      ),
      19,
    );
      await getRoute(
        result["latitude"] as double,
        result["longitude"] as double,
      );
  }
}
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
             initialCenter: LatLng(
             17.550525, 78.165799
             ),
             initialZoom: 17,

              minZoom: 16,
              maxZoom: 20,

              cameraConstraint: CameraConstraint.containCenter(
                bounds: LatLngBounds(
                  const LatLng(17.547199, 78.157142), // southwest
                  const LatLng(17.551956, 78.169802), // northeast
                ),
              ),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.project_1',
              ),
              if (routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: routePoints,
                        strokeWidth: 5,
                        color: Colors.blue,
    ),
  ],
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
if (routePoints.isNotEmpty)
  Positioned(
    bottom: 20,
    left: 20,
    right: 20,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          "${distanceKm.toStringAsFixed(2)} km • "
          "${durationMin.toStringAsFixed(0)} min walk",
          textAlign: TextAlign.center,
        ),
      ),
    ),
  ),
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
        controller: _searchController,
        onSubmitted: _searchLocation,
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

