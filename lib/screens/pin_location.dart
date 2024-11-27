import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';

class PinAddress extends StatefulWidget {
  const PinAddress({super.key});

  @override
  State<PinAddress> createState() => PinAddressState();
}

class PinAddressState extends State<PinAddress>
    with SingleTickerProviderStateMixin {
  String locationMessage = '';
  double? latitude;
  double? longitude;
  bool isLoading = true;
  LatLng? pinnedLocation;
  String? city;
  String? province;
  String? barangay;
  String? streetAddress;
  late AnimationController animationController;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    getLocation();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    animation =
        Tween<double>(begin: 0.9, end: 1.0).animate(animationController);
  }

  Future<void> getLocation() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
        ),
      );
      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
        isLoading = false;
      });
    } else {
      setState(() {
        locationMessage = status.isDenied
            ? 'Location permission denied'
            : 'Location permission permanently denied. Open settings to allow permission.';
        openAppSettings();
        isLoading = false;
      });
    }
  }

  void onTap(LatLng tappedPoint) async {
    setState(() {
      pinnedLocation = tappedPoint;
      latitude = tappedPoint.latitude;
      longitude = tappedPoint.longitude;
      locationMessage =
          'Pinned Location: Latitude: ${tappedPoint.latitude}, Longitude: ${tappedPoint.longitude}';
      animationController.forward(from: 0.0); // Reset animation
    });
    await fetchAddress(tappedPoint); // Fetch address details
    animationController.forward(from: 0.0); // Reset animation
  }

  Future<void> fetchAddress(LatLng location) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );
      if (placemarks.isNotEmpty) {
        setState(() {
          city = placemarks[0].locality;
          province = placemarks[0].administrativeArea;
          streetAddress = placemarks[0].street;
          barangay = placemarks[0].subLocality;
        });
      } 
    } catch (e) {
      ("Error retrieving address: $e");
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void confirmLocation() async {
    if (pinnedLocation != null) {
      // Use reverse geocoding to get address details
      Navigator.pop(context, {
        'latitude': pinnedLocation!.latitude,
        'longitude': pinnedLocation!.longitude,
        'city': city,
        'province': province,
        'barangay': barangay,
        'streetAddress': streetAddress,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pin Address"),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.check,
            ),
            onPressed: confirmLocation,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : latitude != null && longitude != null
              ? FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(latitude!, longitude!),
                    initialZoom: 13.0,
                    minZoom: 5.0,
                    maxZoom: 18.0,
                    onTap: (tapPosition, point) => onTap(point),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                    ),
                    if (pinnedLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: pinnedLocation!,
                            child: ScaleTransition(
                              scale: animation,
                              child: const Icon(
                                Icons.location_on_rounded,
                                size: 40,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                )
              : Center(child: Text(locationMessage)),
      floatingActionButton: FloatingActionButton(
        onPressed: getLocation,
        child: const Icon(Icons.location_searching),
      ),
    );
  }
}
