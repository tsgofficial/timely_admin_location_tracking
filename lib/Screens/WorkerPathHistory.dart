import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Components/Calculate.dart';
import '../Components/WorkerPathList.dart';
import '../Controller/LocatonDataController.dart';

class WorkerPathHistory extends StatefulWidget {
  final DateTime date;
  final String workerId;
  const WorkerPathHistory({
    super.key,
    required this.date,
    required this.workerId,
  });

  @override
  State<WorkerPathHistory> createState() => _WorkerPathHistoryState();
}

class _WorkerPathHistoryState extends State<WorkerPathHistory> {
  final controller = Get.put(LocationDataController());

  @override
  void initState() {
    super.initState();
    controller.getLocData(
      64706, '1', 51955, DateTime.now(),
      // int.parse(widget.workerId.substring(8, 9)),
      // DateFormat('yyyy-MM-dd').parse(widget.date.toString()),
    );
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
        title: Text(
          '${widget.workerId} ажилтаны явсан түүх',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : controller.locData.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(50.0),
                    child: Center(
                      child: Text(
                        'Уг ажилтаны ${widget.date.toString().substring(0, 10)}-ны өдрийн түүх байхгүй байна.',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: 1,
                          // itemCount: locDataController.locDataList.length,
                          itemBuilder: (context, index) {
                            return WorkerPathList(
                              day: Calculating().calculateDay(),
                              date: controller.locData.isNotEmpty
                                  ? controller.locData.last.date!
                                  : DateTime.now(),
                              difference: Calculating().calculateTime(),
                              totalDistance: Calculating().calculateDistance(),
                            );
                          },
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(
                      //     horizontal: 8.0,
                      //     vertical: 5,
                      //   ),
                      //   child: Container(
                      //     decoration: BoxDecoration(
                      //       color: const Color(0xff73BEB2),
                      //       borderRadius: BorderRadius.circular(10),
                      //     ),
                      //     child: Padding(
                      //       padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      //       child: Column(
                      //         children: [
                      //           Row(
                      //             children: const [
                      //               Text(
                      //                 'Niit yvj bui zam: ',
                      //                 style: TextStyle(
                      //                   color: Colors.white,
                      //                   fontSize: 20,
                      //                   fontWeight: FontWeight.bold,
                      //                 ),
                      //               ),
                      //               Text(
                      //                 '10 km',
                      //                 style: TextStyle(
                      //                   color: Colors.white,
                      //                   fontSize: 20,
                      //                   fontWeight: FontWeight.bold,
                      //                 ),
                      //               ),
                      //             ],
                      //           ),
                      //           Row(
                      //             children: const [
                      //               Text(
                      //                 'Niit yvj bui hugatsaa: ',
                      //                 style: TextStyle(
                      //                   color: Colors.white,
                      //                   fontSize: 20,
                      //                   fontWeight: FontWeight.bold,
                      //                 ),
                      //               ),
                      //               Text(
                      //                 '4h 6m',
                      //                 style: TextStyle(
                      //                   color: Colors.white,
                      //                   fontSize: 20,
                      //                   fontWeight: FontWeight.bold,
                      //                 ),
                      //               ),
                      //             ],
                      //           ),
                      //         ],
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
      ),
    );
  }
}
