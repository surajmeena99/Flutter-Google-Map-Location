import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ict_app/const.dart';
import 'package:ict_app/screens/form_screen.dart';
import 'package:location/location.dart' as device_location;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {

  final locationController = TextEditingController();

  // static const vikramNagar = LatLng(23.0300733, 72.501255);
  // static const wideAngle = LatLng(23.024955, 72.50828);

  Position? currentPosition;
  late List<Placemark> placeMarks;
  String completeAddress = "";
  double? _distanceInMeters;

  Map<PolylineId, Polyline> polylines = {};

  late double targetLatitude;
  late double targetLongitude;
  late int targetRadius;

  // Function to fetch target latitude and longitude from Firestore
  fetchFixedLocation() async {
    // Access Firestore collection and document containing target location
    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('fixedLocations').doc('galaEmpire').get();

    // Retrieve latitude and longitude from Firestore document
    targetLatitude = snapshot.data()!['latitude'];
    targetLongitude = snapshot.data()!['longitude'];
    targetRadius = snapshot.data()!['radius'];
  }

  getCurrentLocation() async {
    // Check if location services are enabled
    var location = device_location.Location();
    bool isEnabled = await location.serviceEnabled();
    if (!isEnabled) {
      // Location services are not enabled, request to enable them
      await location.requestService();
      // Check if location services are enabled after the request
      isEnabled = await location.serviceEnabled();
      if (!isEnabled) {
        // Location services are still disabled after the request, display the Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Location services are disabled. Please enable the services'),
            action: SnackBarAction(
              label: 'Enable',
              onPressed: () async {
                // Request to enable location services when the user clicks on "Enable" again
                await location.requestService();
              },
            ),
          ),
        );
        return;
      }
    }

    // Check location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied'))
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are permanently denied, we cannot request permissions.'))
        );
        return;
    }

    // If permissions are granted, return the current location

    Position newPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    currentPosition = newPosition;

    placeMarks = await placemarkFromCoordinates(
      currentPosition!.latitude,
      currentPosition!.longitude,
    );

    Placemark pMark = placeMarks[0];

    completeAddress =
    '${pMark.street}, ${pMark.subLocality}, ${pMark.locality}, ${pMark.administrativeArea}, ${pMark.postalCode}, ${pMark.country}';

    locationController.text = completeAddress;

    // Define the target location
    // const double targetLatitude = 23.024955;
    // const double targetLongitude = 72.50828;

    // Calculate distance
    _distanceInMeters = Geolocator.distanceBetween(
        currentPosition!.latitude,
        currentPosition!.longitude,
        targetLatitude,
        targetLongitude);

    setState(() {});
  }

  checkDistance() {
    if (_distanceInMeters != null && _distanceInMeters! < targetRadius) {
      // If distance is less than 1km, navigate to home screen
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const FormScreen()),
      );
    } else {
      // If distance is greater than or equal to 1km, show snack bar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Distance is greater than from Source Location: $_distanceInMeters meters'),
        ),
      );
    }
  }


  @override
  void initState() {
    super.initState();
    fetchFixedLocation();
    initializeMap();
  }

  Future<void> initializeMap() async{
    await getCurrentLocation();
    final coordinates = await fetchPolylinePoint();
    generatePolyLineFromPoints(coordinates);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Source Location", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
            if (_distanceInMeters != null)
              Text('${(_distanceInMeters!/1000).toStringAsFixed(3)} Km', style: const TextStyle(fontSize: 10),),
            if (_distanceInMeters == null)
              const SizedBox( 
                width: 10, 
                height: 10, 
                child: CircularProgressIndicator(
                  strokeWidth: 2, 
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: (){
              checkDistance();
            }, 
            child: const Text("Continue", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),)
          )
        ],
        automaticallyImplyLeading: false,
      ),
      body: currentPosition == null ? const Center(child: CircularProgressIndicator(),) : Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                currentPosition!.latitude,
                currentPosition!.longitude,
              ),
              zoom: 14.0,
            ),
            markers: {
              Marker(
                markerId: const MarkerId("currentLocation"),
                icon: BitmapDescriptor.defaultMarker,
                position: LatLng(
                  currentPosition!.latitude,
                  currentPosition!.longitude,
                ),
              ),
              Marker(
                markerId: const MarkerId("sourceLocation"),
                icon: BitmapDescriptor.defaultMarker,
                position: LatLng(
                  targetLatitude,
                  targetLongitude,
                ),
              ),
              // const Marker(
              //   markerId: MarkerId("destionationLocation"),
              //   icon: BitmapDescriptor.defaultMarker,
              //   position: wideAngle,
              // ),
            }, 
            // Add the polylines to the map
            polylines: Set<Polyline>.of(polylines.values),
          ),
          Positioned(
            top: 10.0,
            left: 20.0,
            child: Container(
              width: MediaQuery.of(context).size.width*.9,
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1
                ),
                color: Colors.white,
                borderRadius: BorderRadius.circular(10)
              ),
              child: TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.location_on, color: Colors.blue,),
                ),
              ),
            ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: checkDistance,
      //   label: const Text('Continue'),
      //   icon: const Icon(Icons.arrow_forward),
      // ),
    );
  }

  Future<List<LatLng>> fetchPolylinePoint() async{
    if (currentPosition == null) {
      // Handle the case when currentPosition is null
      debugPrint("Current position is null");
      return [];
    }
    final polylinePoints = PolylinePoints();

    final result = await polylinePoints.getRouteBetweenCoordinates(
      googleMapApiKey, 
      PointLatLng(currentPosition!.latitude, currentPosition!.longitude), 
      PointLatLng(targetLatitude, targetLongitude)
    );

    if(result.points.isNotEmpty){
      return result.points.map((point) => LatLng(point.latitude, point.longitude)).toList();
    }else{
      debugPrint(result.errorMessage);
      return [];
    }
  }

  Future<void> generatePolyLineFromPoints(List<LatLng> polylineCoordinates) async{
    const id = PolylineId('polyline');

    final polyline = Polyline(
      polylineId: id,
      color: Colors.blueAccent,
      points: polylineCoordinates,
      width: 5,
    );
    setState(() {
      polylines[id] = polyline;
    });
  }
}