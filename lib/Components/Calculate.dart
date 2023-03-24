import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timely_admin_location/Controller/LocatonDataController.dart';

class Calculating {
  final controller = Get.put(LocationDataController());
  double totalDistance = 0;

  double totalDistanceInMeter = 0;

  double calculateDistance() {
    for (int i = 0; i < controller.locData.length - 1; i++) {
      var p1Lat = double.parse(controller.locData[i].latitude.toString());
      var p1Lng = double.parse(controller.locData[i].longitude.toString());
      var p2Lat = double.parse(controller.locData[i + 1].latitude!);
      var p2Lng = double.parse(controller.locData[i + 1].longitude!);

      double distance = Geolocator.distanceBetween(p1Lat, p1Lng, p2Lat, p2Lng);
      totalDistance += distance;
      totalDistanceInMeter = totalDistance / 1000;
      // print(distance);
      // print(controller.locData.length);
    }
    print('Total distance ${totalDistance / 1000}');
    return totalDistanceInMeter;
  }

  Duration calculateTime() {
    // controller.isLoading.value ?
    DateTime date2 =
        DateTime.parse(controller.locData.first.createdAt.toString());
    DateTime date1 =
        DateTime.parse(controller.locData.last.createdAt.toString());

    Duration difference = date1.difference(date2);
    print('time difference $difference');
    return difference;
  }

  String calculateDay() {
    DateTime dateTime = DateTime.parse(controller.locData.last.date.toString());

    String day = DateFormat('EEEE').format(dateTime);
    switch (day) {
      case 'Monday':
        return 'Даваа';
      case 'Tuesday':
        return 'Мягмар';
      case 'Wednesday':
        return 'Лхагва';
      case 'Thursday':
        return 'Пүрэв';
      case 'Friday':
        return 'Баасан';
      case 'Saturday':
        return 'Бямба';
      case 'Sunday':
        return 'Ням';
      default:
        return 'I do not know this day';
    }
  }
}
