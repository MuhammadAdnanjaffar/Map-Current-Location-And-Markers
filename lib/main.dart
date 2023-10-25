import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late GoogleMapController mapController;
  Set<Marker> markers = {};
  late LatLng originLatLng;
  TextEditingController searchController = TextEditingController();
  TextEditingController secondSearchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Maps Demo',
      home: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (value) {
                      searchLocation(value);
                    },
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: TextField(
                    controller: secondSearchController,
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (value) {
                      searchLocation(value);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        body: GoogleMap(
          onMapCreated: (controller) {
            mapController = controller;
          },
          onTap: (LatLng latLng) {
            print("Latitude and Longitude: $latLng");
            setState(() {
              markers.add(
                Marker(
                  markerId: MarkerId(latLng.toString()),
                  position: latLng,
                  infoWindow: InfoWindow(title: 'Marker'),
                ),
              );
            });
          },
          initialCameraPosition: CameraPosition(
            target: LatLng(33.626057, 73.071442),
            zoom: 12,
          ),
          markers: markers,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            getUserLocation();
          },
          label: Text('My Location'),
          icon: Icon(Icons.location_on),
        ),
      ),
    );
  }

  void getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return;
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition();

    originLatLng = LatLng(position.latitude, position.longitude);
    print('Current Location - Latitude: ${position.latitude}, Longitude: ${position.longitude}');

    setState(() {
      markers.add(
        Marker(
          markerId: MarkerId('current_location'),
          position: originLatLng,
          infoWindow: InfoWindow(title: 'Current Location'),
        ),
      );

      mapController.animateCamera(CameraUpdate.newLatLngZoom(originLatLng, 12));
    });
  }

  void searchLocation(String address) async {
    List<Location> locations = await GeocodingPlatform.instance.locationFromAddress(address);
    if (locations.isNotEmpty) {
      Location location = locations.first;
      LatLng searchLatLng = LatLng(location.latitude, location.longitude);
      print('Search Location - Latitude: ${searchLatLng.latitude}, Longitude: ${searchLatLng.longitude}');

      setState(() {
        markers.add(
          Marker(
            markerId: MarkerId('search_location'),
            position: searchLatLng,
            infoWindow: InfoWindow(title: 'Search Location'),
          ),
        );

        mapController.animateCamera(CameraUpdate.newLatLngZoom(searchLatLng, 12));
      });
    }
  }
}
