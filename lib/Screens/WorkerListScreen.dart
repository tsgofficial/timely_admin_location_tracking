import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:timely_admin_location/Components/CustomColors%20(2).dart';
import 'package:timely_admin_location/Controller/LocatonDataController.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:timely_admin_location/Controller/SocketStreamController.dart';
import 'package:uuid/uuid.dart';
import 'WorkerPathHistory.dart';

class WorkerListScreen extends StatefulWidget {
  const WorkerListScreen({super.key});

  @override
  State<WorkerListScreen> createState() => _WorkerListScreenState();
}

class _WorkerListScreenState extends State<WorkerListScreen> {
  final locDataController = Get.put(LocationDataController());
  final socketController = Get.put(SocketStreamController());

  // IO.Socket socket = IO.io('https://api.timely.mn/', <String, dynamic>{
  //   "transports": ["websocket"],
  // });

  IO.Socket socket = IO.io('http://16.162.14.221:4000/', <String, dynamic>{
    'transports': ['websocket'],
  });

  var uniqueId = const Uuid().v4();

  var dataList = [];

  @override
  void initState() {
    super.initState();
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
      (data) => {
        socketController.locDataList.add(
          LatLng(data["latitude"], data["longitude"]),
        ),
        print("latitude: ${data["latitude"]}"),
        print("longitude: ${data["longitude"]}"),
        dataList.add(data),
        print("dataList length: ${dataList.length}"),
        print("data ni: $data"),
      },
    );
  }

  DateTime _selectedDate = DateTime.now();

  ThemeData pickerTheme = ThemeData(
    primaryColor: Colors.red, // set accent color
    textTheme: const TextTheme(
      titleLarge: TextStyle(color: Colors.green), // set headline color
    ),
    colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.yellow),
  );

  Future<void> _selectDate1(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: CustomColors.MAIN_BLUE, // <-- SEE HERE
                onPrimary: Colors.white,
                onSurface: CustomColors.MAIN_BLUE, // <-- SEE HERE
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: CustomColors.MAIN_BLUE, // button text color
                ),
              ),
            ),
            child: child!,
          );
        });
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      // Navigator.pop(context, picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.grey,
        elevation: 3, // set the elevation to create a shadow effect
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(
                20), // set the bottom radius to create a rounded effect
          ),
        ),
        title: const Text(
          'Ажилтаны жагсаалт',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: InkWell(
              onTap: () {
                _selectDate1(context);
              },
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: _selectedDate != null
                    ? Text(DateFormat('yyyy-MM-dd')
                        .format(_selectedDate)
                        .toString())
                    : Text(DateFormat('yyyy-MM-dd')
                        .format(DateTime.now())
                        .toString()),
              ),
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: ListView.builder(
        itemCount: 3,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              receivedData(51955);
              Get.to(
                () => WorkerPathHistory(
                  date: _selectedDate,
                  workerId: 'userId: ${index + 1}',
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 5,
              ),
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'user_id: ${index + 1}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
