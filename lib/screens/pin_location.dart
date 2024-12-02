// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:geocoding/geocoding.dart';

// class PinAddress extends StatefulWidget {
//   const PinAddress({super.key});

//   @override
//   State<PinAddress> createState() => PinAddressState();
// }

// class PinAddressState extends State<PinAddress>
//     with SingleTickerProviderStateMixin {
//   String locationMessage = '';
//   double? latitude;
//   double? longitude;
//   bool isLoading = true;
//   LatLng? pinnedLocation;
//   String? city;
//   String? province;
//   String? barangay;
//   String? streetAddress;
//   late AnimationController animationController;
//   late Animation<double> animation;

//   @override
//   void initState() {
//     super.initState();
//     getLocation();
//     animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//     );
//     animation =
//         Tween<double>(begin: 0.9, end: 1.0).animate(animationController);
//   }

//   Future<void> getLocation() async {
//     var status = await Permission.location.request();
//     if (status.isGranted) {
//       Position position = await Geolocator.getCurrentPosition(
//         locationSettings: const LocationSettings(
//           accuracy: LocationAccuracy.best,
//         ),
//       );
//       setState(() {
//         latitude = position.latitude;
//         longitude = position.longitude;
//         pinnedLocation = LatLng(latitude!, longitude!); // Set default pin
//         isLoading = false;
//       });
//       await fetchAddress(pinnedLocation!); // Fetch address for current location
//     } else {
//       setState(() {
//         locationMessage = status.isDenied
//             ? 'Location permission denied'
//             : 'Location permission permanently denied. Open settings to allow permission.';
//         openAppSettings();
//         isLoading = false;
//       });
//     }
//   }

//   void onTap(LatLng tappedPoint) async {
//     setState(() {
//       pinnedLocation = tappedPoint;
//       latitude = tappedPoint.latitude;
//       longitude = tappedPoint.longitude;
//       locationMessage =
//           'Pinned Location: Latitude: ${tappedPoint.latitude}, Longitude: ${tappedPoint.longitude}';
//       animationController.forward(from: 0.0); // Reset animation
//     });
//     await fetchAddress(tappedPoint); // Fetch address details
//     animationController.forward(from: 0.0); // Reset animation
//   }

//   Future<void> fetchAddress(LatLng location) async {
//     try {
//       List<Placemark> placemarks = await placemarkFromCoordinates(
//         location.latitude,
//         location.longitude,
//       );
//       if (placemarks.isNotEmpty) {
//         setState(() {
//           city = placemarks[0].locality;
//           province = placemarks[0].administrativeArea;
//           streetAddress = placemarks[0].street;
//           barangay = placemarks[0].subLocality;
//         });
//       }
//     } catch (e) {
//       ("Error retrieving address");
//     }
//   }

//   @override
//   void dispose() {
//     animationController.dispose();
//     super.dispose();
//   }

//   void confirmLocation() async {
//     if (pinnedLocation != null) {
//       // Use reverse geocoding to get address details
//       Navigator.pop(context, {
//         'latitude': pinnedLocation!.latitude,
//         'longitude': pinnedLocation!.longitude,
//         'city': city,
//         'province': province,
//         'barangay': barangay,
//         'streetAddress': streetAddress,
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Pin Address"),
//         actions: [
//           IconButton(
//             icon: const Icon(
//               Icons.check,
//             ),
//             onPressed: confirmLocation,
//           ),
//         ],
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : latitude != null && longitude != null
//               ? FlutterMap(
//                   options: MapOptions(
//                     initialCenter: pinnedLocation ?? LatLng(0, 0),
//                     initialZoom: 13.0,
//                     minZoom: 5.0,
//                     maxZoom: 18.0,
//                     onTap: (tapPosition, point) => onTap(point),
//                   ),
//                   children: [
//                     TileLayer(
//                       urlTemplate:
//                           'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
//                       userAgentPackageName: 'com.example.app',
//                     ),
//                     if (pinnedLocation != null)
//                       MarkerLayer(
//                         markers: [
//                           Marker(
//                             point: pinnedLocation!,
//                             child: ScaleTransition(
//                               scale: animation,
//                               child: const Icon(
//                                 Icons.location_on_rounded,
//                                 size: 40,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                   ],
//                 )
//               : Center(child: Text(locationMessage)),
//       floatingActionButton: FloatingActionButton(
//         onPressed: getLocation,
//         child: const Icon(Icons.location_searching),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';
import 'package:service_provider/components/globals.dart';

class PinLocationNew extends StatefulWidget {
  const PinLocationNew({super.key});

  @override
  State<PinLocationNew> createState() => _PinLocationNewState();
}

class _PinLocationNewState extends State<PinLocationNew> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: OpenStreetMapSearchAndPick(
      buttonTextStyle: const TextStyle(fontSize: regularText),
      locationPinText: '',
      locationPinIconColor: primaryColor,
      buttonColor: primaryColor,
      buttonText: 'Set Current Location',
      onPicked: (pickedData) {
        print('Picked Data: $pickedData'); // Log the picked data
        // Pass only the addressName back to the previous screen
        Navigator.pop(context, {
          'latitude': pickedData.latLong.latitude,
          'longitude': pickedData.latLong.longitude,
          'address': pickedData.addressName,
        });
      },
    ));
  }
}
