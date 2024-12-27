import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
//import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:map_location_picker/map_location_picker.dart';
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

  PlacesDetailsResponse? selectedPlace;
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
      /* appBar: AppBar(), */
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
            child: MapLocationPicker(
              apiKey: GOOGLE_MAP_API_KEY,
              searchHintText: language.findPlace,

              /* 
              searchingText: language.pleaseWait,
              sele: language.selectPlace,
              outsideOfPickAreaText: language.placeNotInArea, */
              currentLatLng: LatLng(sharedPref.getDouble(LATITUDE)!,
                  sharedPref.getDouble(LONGITUDE)!),
              /* useCurrentLocation: true,
              selectInitialPosition: true,
              usePinPointingSearch: true,
              usePlaceDetailSearch: true,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: true,
              automaticallyImplyAppBarLeading: false,
              autocompleteLanguage: '', */
              /* onGeocodingSearchFailed: ((value) async {
                isDemo = true;
                setState(() {});
                await Future.delayed(Duration(seconds: 2)).whenComplete(() {
                  isDemo = false;
                  setState(() {});
                });
              }), */

              /*  onCameraMoveStarted: ((p0) {
                isDemo = false;
                setState(() {});
              }),
              pinBuilder: ((context, state) {
                return Image.asset(
                  widget.isDestination == true ? DestinationIcon : SourceIcon,
                  height: 40,
                  width: 40,
                );
              }), */
              /* onMapCreated: (GoogleMapController controller) {
                //
              }, */
              onSuggestionSelected: (PlacesDetailsResponse? result) {
                print("a");
                setState(() {
                  selectedPlace = result;
                  log(selectedPlace!.result.formattedAddress);
                  Navigator.pop(context, selectedPlace);
                });
              },
              /* onMapTypeChanged: (MapType mapType) {
                //
              }, */
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
