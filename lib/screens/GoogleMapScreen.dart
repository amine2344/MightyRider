import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:taxi_booking/utils/Colors.dart';
import '../main.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/app_common.dart';
import '../utils/images.dart';

class GoogleMapScreen extends StatefulWidget {
  final bool? isDestination;

  const GoogleMapScreen({super.key, this.isDestination});

  @override
  GoogleMapScreenState createState() => GoogleMapScreenState();
}

class GoogleMapScreenState extends State<GoogleMapScreen> {
  LatLng kInitialPosition = polylineSource;

  PickResult? selectedPlace;
  bool showPlacePickerInContainer = false;
  bool showGoogleMapInContainer = false;
  bool isDemo = false;

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Theme(
            data: ThemeData(
                colorScheme: ColorScheme.light(primary: primaryColor),
                progressIndicatorTheme: ProgressIndicatorThemeData(
                  color: Colors.white,
                  circularTrackColor: primaryColor,
                  refreshBackgroundColor: primaryColor,
                  linearTrackColor: primaryColor,
                ),
                scaffoldBackgroundColor: Colors.white,
                iconTheme: IconThemeData(color: Colors.black)),
            child: PlacePicker(
              apiKey: GOOGLE_MAP_API_KEY,
              hintText: language.findPlace,
              searchingText: language.pleaseWait,
              selectText: language.selectPlace,
              outsideOfPickAreaText: language.placeNotInArea,
              initialPosition: LatLng(sharedPref.getDouble(LATITUDE)!,
                  sharedPref.getDouble(LONGITUDE)!),
              useCurrentLocation: false,
              selectInitialPosition: false,
              //usePinPointingSearch: false,
              usePlaceDetailSearch: false,
              zoomGesturesEnabled: false,
              zoomControlsEnabled: false,
              automaticallyImplyAppBarLeading: false,
              autocompleteLanguage: '',
              onGeocodingSearchFailed: ((value) async {
                print(value);
                isDemo = true;
                setState(() {});
                await Future.delayed(Duration(seconds: 2)).whenComplete(() {
                  isDemo = false;
                  setState(() {});
                });
              }),
              onCameraMoveStarted: ((p0) {
                isDemo = false;
                setState(() {});
              }),
              pinBuilder: ((context, state) {
                return Image.asset(
                  widget.isDestination == true ? DestinationIcon : SourceIcon,
                  height: 40,
                  width: 40,
                );
              }),
              onMapCreated: (GoogleMapController controller) {
                //
              },
              onPlacePicked: (PickResult result) {
                setState(() {
                  selectedPlace = result;
                  log(selectedPlace!.formattedAddress);
                  Navigator.pop(context, selectedPlace);
                });
              },
              onMapTypeChanged: (MapType mapType) {
                //
              },
            ),
          ),
          if (isDemo == true)
            Container(
              margin: EdgeInsets.only(top: 120),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: radius(),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 2,
                      spreadRadius: 1),
                ],
              ),
              child: Text(
                'NOTE: Drag-drop address place search is disable \nfor demo user',
                style: secondaryTextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

/* import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GoogleMapScreen extends StatefulWidget {
  final bool? isDestination;
  final Function(PickResult)?
      onPlacePicked; // Callback to return the picked place

  const GoogleMapScreen({super.key, this.isDestination, this.onPlacePicked});

  @override
  GoogleMapScreenState createState() => GoogleMapScreenState();
}

class GoogleMapScreenState extends State<GoogleMapScreen> {
  GoogleMapController? _controller;
  Set<Marker> _markers = {};
  LatLng? _pickedLocation;
  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pick a Location'),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                  37.42796133580664, -122.085749655962), // Default location
              zoom: 15,
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
            },
            onTap: (LatLng location) async {
              setState(() {
                _pickedLocation = location;
                _markers.clear();
                _markers.add(
                  Marker(
                    markerId: MarkerId('picked_location'),
                    position: location,
                    infoWindow: InfoWindow(title: 'Picked Location'),
                  ),
                );
              });
              // Perform reverse geocoding to get address
              await _getAddress(location);
            },
            markers: _markers,
          ),

          // Search Bar for Place Search
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Place',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.black),
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () async {
                    String searchQuery = _searchController.text;
                    if (searchQuery.isNotEmpty) {
                      // Call search function (you can use Google Places API or any other service)
                      await _searchPlace(searchQuery);
                    }
                  },
                ),
              ),
            ),
          ),

          // Display the picked location's coordinates
          if (_pickedLocation != null)
            Positioned(
              bottom: 20,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                color: Colors.white,
                child: Text(
                  'Lat: ${_pickedLocation!.latitude}, Lon: ${_pickedLocation!.longitude}',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Function to perform reverse geocoding (get address from latitude & longitude)
  Future<void> _getAddress(LatLng location) async {
    final response = await http.get(Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${location.latitude}&lon=${location.longitude}'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      String address = data['address']['road'] ?? 'Unknown location';
      print('Picked address: $address');
      // Simulate returning a PickResult
      PickResult result = PickResult(
        formattedAddress: address,
        geometry:
            Geometry(location: Location(location.latitude, location.longitude)),
      );
      // Call the onPlacePicked callback
      if (widget.onPlacePicked != null) {
        widget.onPlacePicked!(result);
      }
      Navigator.pop(context, result); // Pop the screen and return the result
    } else {
      print('Failed to get address');
    }
  }

  // Function to search for a place (you can implement this with Google Places or a free API)
  Future<void> _searchPlace(String query) async {
    // Example: OpenStreetMap Nominatim API
    final response = await http.get(Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=json&q=$query'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.isNotEmpty) {
        // Get the first search result
        var location = data[0];
        double lat = double.parse(location['lat']);
        double lon = double.parse(location['lon']);

        // Update map with the found location
        setState(() {
          _pickedLocation = LatLng(lat, lon);
          _markers.clear();
          _markers.add(
            Marker(
              markerId: MarkerId('searched_location'),
              position: _pickedLocation!,
              infoWindow: InfoWindow(title: 'Searched Location'),
            ),
          );
        });
        // Move camera to the new location
        _controller
            ?.animateCamera(CameraUpdate.newLatLngZoom(_pickedLocation!, 15));

        // Simulate returning a PickResult
        PickResult result = PickResult(
          formattedAddress: location['display_name'],
          geometry: Geometry(location: Location(lat, lon)),
        );
        // Call the onPlacePicked callback
        if (widget.onPlacePicked != null) {
          widget.onPlacePicked!(result);
        }
        Navigator.pop(context, result); // Pop the screen and return the result
      } else {
        print('No results found for $query');
      }
    } else {
      print('Failed to search for place');
    }
  }
}

class PickResult {
  final String formattedAddress;
  final Geometry geometry;

  PickResult({required this.formattedAddress, required this.geometry});
}

class Geometry {
  final Location location;

  Geometry({required this.location});
}

class Location {
  final double lat;
  final double lng;

  Location(this.lat, this.lng);
}
 */