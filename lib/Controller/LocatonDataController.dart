import 'package:get/get.dart';
import 'package:timely_admin_location/Repos/ApiService.dart';

import '../Model/LocDataModel.dart';

class LocationDataController extends GetxController {
  var isLoading = false.obs;
  var locDataModel = LocationDataModel().obs;

  RxList<LocationData> locData = RxList<LocationData>();

  Future<void> getLocData(
      int id, String token, int userId, DateTime date) async {
    isLoading.value = true;
    LocationDataModel locationDataModel =
        await ApiService().getLocData(id, token, userId, date);
    locDataModel.value = locationDataModel;
    locData.value = locationDataModel.data!;
    isLoading.value = false;
    print(locData.length);
    print(locData.last.latitude);
  }
}
