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
import 'package:project_1/screens/map_page.dart';
import 'dart:ui';
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  

  @override
  State<HomePage> createState() => _HomePageState();
}
bool followUser = false;
bool showSearchBar = false;

final TextEditingController _searchController =
    TextEditingController();
class _HomePageState extends State<HomePage> {
  String? _mapStyle;
  Position? currentPosition;
  int selectedIndex = 0;
  bool isSearchOpen = false;
final ScrollController _scrollController =
    ScrollController();

final MapController _mapController = MapController();
double heading = 0;
  List<LatLng> routePoints = [];
  void _goToMyLocation() {
  if (currentPosition == null) return;

  _mapController.move(
    LatLng(
      currentPosition!.latitude,
      currentPosition!.longitude,
    ),
    18.0, // zoom level
  );
}

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
PreferredSizeWidget glassAppBar() {
  return PreferredSize(
    preferredSize: const Size.fromHeight(90),
    child: ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 5,
          sigmaY: 5,
        ),
        child: Container(
          height: 90,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.green.withValues(alpha: 0.08),
            border: Border(
              bottom: BorderSide(
                color: Colors.green.withValues(alpha: 0.15),
              ),
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  color: const Color(0xFF007367),
                  onPressed: () {},
                ),

                const Expanded(
                  child: Center(
                    child: Text(
                      "GITAM Maps",
                      style: TextStyle(
                        color: Color(0xFF007367),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.settings),
                  color: const Color(0xFF007367),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
@override
void initState() {
  super.initState();
  _loadMapStyle();
  _getCurrentLocation();
  void _goToMyLocation() {
  if (currentPosition != null) {
    _mapController.move(
      LatLng(
        currentPosition!.latitude,
        currentPosition!.longitude,
      ),
      18,
    );
  }
}
  Geolocator.getPositionStream(
  locationSettings: const LocationSettings(
    accuracy: LocationAccuracy.best,
  ),
).
listen((Position position) {
  setState(() {
    currentPosition = position;
  });
  if (followUser) {
  _mapController.move(
    LatLng(position.latitude, position.longitude),
    _mapController.camera.zoom,
  );
}
});


_scrollController.addListener(() {
  if (_scrollController.offset > 50) {
    // shrink bar
  } else {
    // expand bar
  }
});

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
Widget _navItem(
  IconData icon,
  String label,
  int index,
) {
  bool selected = selectedIndex == index;

  return AnimatedContainer(
    duration: const Duration(milliseconds: 250),
    padding: const EdgeInsets.symmetric(
      horizontal: 18,
      vertical: 6,
    ),
    decoration: BoxDecoration(
      color: selected
          ? Colors.black.withValues(alpha: 0.35)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(30),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: selected ? Colors.white : Colors.white70,
          size: 24,
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            color:
                selected ? Colors.white : Colors.white70,
            fontSize: 12,
            fontWeight: selected
                ? FontWeight.w600
                : FontWeight.w400,
          ),
        ),
      ],
    ),
  );
}

Widget _glassNavBar() {
  return ClipRRect(
    borderRadius: BorderRadius.circular(40),
    child: BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: 5,
        sigmaY: 5,
      ),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          color: Colors.green.withValues(alpha: 0.08),
          border: Border.all(
            color: Colors.green.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = 0;
        });
      },
      child: _navItem(
        Icons.home_rounded,
        "Home",
        0,
      ),
    ),

    GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = 1;
        });
      },
      child: _navItem(
        Icons.explore_rounded,
        "Map",
        1,
      ),
    ),

    GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = 2;
        });
      },
      child: _navItem(
        Icons.person_rounded,
        "Profile",
        2,
      ),
    ),
  ],
)
      ),
    ),
  );
}
Widget _searchBubble() {
  return GestureDetector(
  onTap: () {
  setState(() {
    showSearchBar = !showSearchBar;
  });
},
    child: ClipRRect(
  borderRadius: BorderRadius.circular(40),
  child: BackdropFilter(
    filter: ImageFilter.blur(
      sigmaX: 5,
      sigmaY: 5,
    ),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 65,
      height: 65,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.green.withValues(alpha: 0.08),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.18),
        ),
      ),
      child: const Icon(
        Icons.search,
        color: Colors.white,
      ),
    ),
  ),
)
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: glassAppBar(),
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
          if (showSearchBar)
  Positioned(
    top: 100,
    left: 20,
    right: 20,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 5,
            sigmaY: 5,
          ),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.18),
              ),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(
                color: Colors.black,
              ),
              onSubmitted: (value) {
                _searchLocation(value);
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.black54,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      showSearchBar = false;
                    });
                  },
                ),
                hintText: "  Search for a location",
              ),
            ),
          ),
        ),
      ),
    ),
  ),
          
Positioned(
  right: 20,
  bottom: 100,
  child: GestureDetector(
    onTap: _goToMyLocation,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 5,
          sigmaY: 5,
        ),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.green.withValues(alpha: 0.18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.my_location,
            color: Colors.white,
          ),
        ),
      ),
    ),
  ),
),

if (routePoints.isNotEmpty)
  Positioned(
    bottom: 100,
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
      ),
 bottomNavigationBar: SizedBox(
  height: 100,
  child: Stack(
    children: [

      // Main Glass Navigation Bar
      Positioned(
        left: 16,
        right: 90,
        bottom: 10,
        child: _glassNavBar(),
      ),

      // Search Bubble
      Positioned(
        right: 16,
        bottom: 10,
        child: _searchBubble(),
      ),
    ],
  ),
),
    );
  }
      
  }

