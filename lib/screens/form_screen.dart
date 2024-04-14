import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ict_app/screens/tabs_screen.dart';
import 'package:location/location.dart' as device_location;

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {

  late String selectedYear;
  late String selectedDistrict;
  late String selectedWaterSource;
  late String selectedDeliveryPoint;

  List<String> years = ['Select', '2023', '2024', '2025'];
  List<String> district = ['Select', 'Ahmedabad', 'Rajkot', 'Surat'];
  List<String> waterSource = ['Select', 'Bore well', 'Open well', 'Hand Pump', 'Multi village scheme(MVS)'];
  List<String> deliveryPoint = ['Select', 'FHTC', 'WPP(Water Purification Plant)', 'Schools', 'Anganwadis'];

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final dobController = TextEditingController();
  final locationController = TextEditingController();

  String name = "", dob = "";

  Position? position;
  late List<Placemark> placeMarks;
  String completeAddress = "";

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
            content: Text('Location services are disabled. Please enable the services'),
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
          SnackBar(content: Text('Location permissions are denied'))
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permissions are permanently denied, we cannot request permissions.'))
        );
        return;
    }

    // If permissions are granted, return the current location

    Position newPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    position = newPosition;

    placeMarks = await placemarkFromCoordinates(
      position!.latitude,
      position!.longitude,
    );

    Placemark pMark = placeMarks[0];

    completeAddress =
    '${pMark.street}, ${pMark.subLocality}, ${pMark.locality}, ${pMark.administrativeArea}, ${pMark.postalCode}, ${pMark.country}';

    locationController.text = completeAddress;
  }

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  submitForm()async{
    await FirebaseFirestore.instance.collection('users')
          .doc(firebaseAuth.currentUser!.uid)
          .update({
            'Name': name,
            'DOB': dob,
            'Address': completeAddress,
            'Financial Year': selectedYear,
            'District': selectedDistrict,
            'Water Supply Source': selectedWaterSource,
            'Delivery Point Source': selectedDeliveryPoint,
            'lat': position!.latitude, 
            'lng': position!.longitude, 
          });
    
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const TabsScreen()));
  }

  @override
  void initState() {
    super.initState();
    selectedYear = years.first; 
    selectedDistrict = district.first;
    selectedWaterSource = waterSource.first;
    selectedDeliveryPoint = deliveryPoint.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    child: const Text("Registration Form", 
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: const Text("Enter Your Name:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: nameController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please Enter Name";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      hintText: 'Enter Full Name',
                      labelText: 'Name',
                      prefixIcon: const Icon(Icons.person, color: Colors.blue,),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: const Text("Enter Your DOB:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: dobController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please Enter DOB";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      hintText: 'Enter DOB',
                      labelText: 'DOB',
                      prefixIcon: const Icon(Icons.calendar_month, color: Colors.blue,),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: const Text("Choose Financial Year:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)
                  ),
                  const SizedBox(height: 5),
                  DropdownButtonFormField(
                    value: selectedYear,
                    items: years.map((item) {
                      return DropdownMenuItem(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedYear = value!;
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)
                      ),
                      // labelText: 'Select Class:',
                      // labelStyle: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black)
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: const Text("Choose District:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)
                  ),
                  const SizedBox(height: 5),
                  DropdownButtonFormField(
                    value: selectedDistrict,
                    items: district.map((item) {
                      return DropdownMenuItem(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDistrict = value!;
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: const Text("Select Water Supply Source:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)
                  ),
                  const SizedBox(height: 5),
                  DropdownButtonFormField(
                    value: selectedWaterSource,
                    items: waterSource.map((item) {
                      return DropdownMenuItem(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedWaterSource = value!;
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: const Text("Select Delivery Point Source:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)
                  ),
                  const SizedBox(height: 5),
                  DropdownButtonFormField(
                    value: selectedDeliveryPoint,
                    items: deliveryPoint.map((item) {
                      return DropdownMenuItem(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDeliveryPoint = value!;
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: const Text("Enter Your Address:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: locationController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please Enter Address";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      hintText: 'Enter Address',
                      labelText: 'Address',
                      prefixIcon: const Icon(Icons.location_on, color: Colors.blue,),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 5,),
                  Container(
                    width: 400,
                    height: 40,
                    alignment: Alignment.center,
                    child: ElevatedButton.icon(
                      label: const Text(
                        "Get my Current Location",
                        style: TextStyle(color: Colors.white),
                      ),
                      icon: const Icon(
                        Icons.location_on,
                        color: Colors.white,
                      ),
                      onPressed: () async{
                        getCurrentLocation();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    height: 50,
                    width: MediaQuery.of(context).size.width * 0.90,
                    child: ElevatedButton(
                      onPressed: () async{
                        if (formKey.currentState!.validate()) {
                          setState(() {
                            name= nameController.text;
                            dob= dobController.text;
                          });
                          await submitForm();
                        }
                      }, 
                      style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                        overlayColor: MaterialStateProperty.all(Colors.white.withOpacity(0.4)),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                        ),
                      ),
                      child: const Text("Submit", style: TextStyle(fontSize: 16))
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}