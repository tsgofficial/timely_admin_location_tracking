import 'dart:async';

// import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:timely_admin_location/Components/Calculate.dart';
import 'package:timely_admin_location/Controller/GoogleMapController.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../Components/CustomColors (2).dart';
import '../Controller/LocatonDataController.dart';
// import 'package:geoloca';

class DetailedMapScreen extends StatefulWidget {
  final DateTime date;
  final double totalDistance;
  final String totalTime;
  const DetailedMapScreen({
    super.key,
    required this.date,
    required this.totalDistance,
    required this.totalTime,
  });

  @override
  State<DetailedMapScreen> createState() => _DetailedMapScreenState();
}

class _DetailedMapScreenState extends State<DetailedMapScreen> {
  final controller = Get.put(LocationDataController());
  final googleMapsController = Get.put(GoogleMapsController());

  List<LatLng> locDataList = [];
  @override
  void initState() {
    super.initState();
    // polylinePoints = PolylinePoints();
    reqPermission();
    getLocs();
    socket.connect();
    if (socket.connected) {
      print('socket connected!');
    } else {
      print('couldnt connect');
    }
    socket.onConnect((data) async {
      print('socket connected !!!');
    });
    receivedData(51955);
  }

  void receivedData(int desiredUserId) async {
    var request = {
      "userId": 1782,
      "desiredUser": desiredUserId,
    };
    socket.emit("auth", request);
    socket.on('auth_result', (data) {
      {
        print("nogoo data getsen ym ni: $data");
        // String jsonString = String.fromCharCodes(data);
        // var receivedData = json.decode(jsonString);
        if (data['success']) {
          print('success');
        } else {
          print('fail');
        }
      }
    });
    // socket.stream/
    socket.on(
      'location',
      (data) {
        {
          // locDataList.add(data);
          print("dataList length: ${locDataList.length}");
          print("data ni: $data");
          LatLng location = LatLng(data["latitude"], data["longitude"]);
          updateMap(location);
        }
      },
      // updateMap);
    );
  }

  void updateMap(LatLng location) async {
    setState(() {
      endMarker1 = Marker(
        markerId: const MarkerId('start_marker'),
        position: location,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      );
      polylineCoordinates.add(location);
      _polylines.add(
        Polyline(
          color: CustomColors.MAIN_BLUE,
          width: 7,
          polylineId: const PolylineId('polyline_id'),
          points: polylineCoordinates,
        ),
      );
    });
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: location,
          zoom: 5,
        ),
      ),
    );
  }

  IO.Socket socket = IO.io('http://16.162.14.221:4000/', <String, dynamic>{
    'transports': ['websocket'],
  });

  List<LatLng> polylineCoordinates = [];
  bool isLoading = false;

  void getLocs() {
    googleMapsController.isLoading.value = true;
    for (int i = 0; i < controller.locData.length - 1; i++) {
      polylineCoordinates.add(
        LatLng(
          double.parse(controller.locData[i].latitude!),
          double.parse(controller.locData[i].longitude!),
        ),
      );
    }
    setPolylines();
    googleMapsController.isLoading.value = false;
  }

  late final CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(
      double.parse(controller.locData.first.latitude!),
      double.parse(controller.locData.first.longitude!),
    ),
    zoom: 5,
  );

  late Marker startMarker1 = Marker(
    markerId: const MarkerId('start_marker'),
    position: LatLng(
      double.parse(controller.locData.first.latitude!),
      double.parse(controller.locData.first.longitude!),
    ),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
  );

  late Marker endMarker1 = Marker(
    markerId: const MarkerId('start_marker'),
    position: LatLng(
      double.parse(controller.locData.last.latitude!),
      double.parse(controller.locData.last.longitude!),
    ),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
  );

  late LatLng currentLocation;
  late LatLng destinationLocation;

  final Set<Polyline> _polylines = <Polyline>{};
  // late PolylinePoints polylinePoints;

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  // double totalDistance = 0.0;
  // double kmTotalDistance = 0.0;
  // void estimateDistance() {
  //   for (int i = 0; i < polylineCoordinates.length - 1; i++) {
  //     LatLng p1 = polylineCoordinates[i];
  //     LatLng p2 = polylineCoordinates[i + 1];
  //     double distance = Geolocator.distanceBetween(
  //         p1.latitude, p1.longitude, p2.latitude, p2.longitude);
  //     totalDistance += distance;
  //     kmTotalDistance = totalDistance / 1000;
  //   }
  // }

  Future<void> reqPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also wheres
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
  }

  void setPolylines() {
    setState(() {
      _polylines.add(
        Polyline(
          color: CustomColors.MAIN_BLUE,
          width: 7,
          polylineId: const PolylineId('polyline_id'),
          points: polylineCoordinates,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Get.back();
              socket.disconnect();
              polylineCoordinates.clear();
            },
            icon: const Icon(Icons.arrow_back_ios),
          ),
          shadowColor: Colors.grey,
          elevation: 3, // set the elevation to create a shadow effect
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(
                  20), // set the bottom radius to create a rounded effect
            ),
          ),
          title: Text(
            '${widget.date.toString().substring(0, 10)}-ны явсан зам',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 5,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: CustomColors.MAIN_BLUE,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Нийт явж буй зам: ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${Calculating().calculateDistance().toString().substring(0, 5)} км',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text(
                            'Нийт явж буй хугацаа: ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${widget.totalTime.toString().substring(0, 1)} ц'
                            ' ${widget.totalTime.toString().substring(2, 4)} м',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Obx(
              () => googleMapsController.isLoading.value
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : SizedBox(
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5.0,
                          vertical: 5,
                        ),
                        child: GoogleMap(
                          // myLocationButtonEnabled: true,
                          // myLocationEnabled: true,
                          markers: <Marker>{
                            startMarker1,
                            endMarker1,
                          },
                          onMapCreated: (GoogleMapController controller) {
                            _controller.complete(controller);
                            // setPolylines();
                            getLocs();
                          },
                          polylines: _polylines,
                          initialCameraPosition: _initialCameraPosition,
                          mapType: MapType.normal,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
