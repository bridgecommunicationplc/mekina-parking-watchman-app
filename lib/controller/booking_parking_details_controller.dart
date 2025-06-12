import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:watchman/model/order_model.dart';
import 'package:watchman/model/parking_model.dart';
import 'package:watchman/model/user_model.dart';
import 'package:watchman/model/user_vehicle_model.dart';
import 'package:watchman/utils/fire_store_utils.dart';

class BookingParkingDetailsController extends GetxController {
  RxBool isLoading = false.obs;
  RxString currentMonth = DateFormat.yMMMM().format(DateTime.now()).obs;
  Rx<DateTime> selectedDateTime = DateTime.now().obs;
  RxDouble selectedDuration = 1.0.obs;

  Rx<ParkingModel> parkingModel = ParkingModel().obs;
  RxList<UserModel> allUserList = <UserModel>[].obs;
  Rx<UserModel> selectedUserModel = UserModel().obs;

  Rx<DateTime> startTime = DateTime.now().obs;
  Rx<DateTime> endTime = DateTime.now().obs;

  Rx<TextEditingController> startTimeController = TextEditingController().obs;
  Rx<TextEditingController> endTimeController = TextEditingController().obs;
  Rx<TextEditingController> vehiclePlateController =
      TextEditingController().obs;
  Rx<TextEditingController> customerNameController =
      TextEditingController().obs;
  Rx<TextEditingController> phoneNumberController = TextEditingController().obs;

  Rx<TextEditingController> countryCode =
      TextEditingController(text: "+251").obs;

  GlobalKey<FormFieldState> key = GlobalKey<FormFieldState>();
  GlobalKey<FormFieldState> vehicleKey = GlobalKey<FormFieldState>();

  Rx<UserVehicleModel> selectedVehicle = UserVehicleModel().obs;
  RxList<UserVehicleModel> userVehicle = <UserVehicleModel>[].obs;

  RxList<UserVehicleModel> allUserVehicle = <UserVehicleModel>[].obs;
  Rx<UserVehicleModel> selectedUserVehicleModel = UserVehicleModel().obs;
  RxList<UserModel> user = <UserModel>[].obs;
  Rx<UserModel> selectedUser = UserModel().obs;
  RxString selectedParking = "".obs;
  Rx<OrderModel> orderModel = OrderModel().obs;

  @override
  void onInit() {
    getAllUser();
    getArgument();
    super.onInit();
  }

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      parkingModel.value = argumentData['parkingModel'];
      getParkingDetails();
      // getBookedParking();
    }

    startTimeController.value.text =
        DateFormat('HH:mm').format(startTime.value);
    Duration duration = Duration(hours: selectedDuration.value.toInt());

    endTime.value = startTime.value.add(duration);
    endTimeController.value.text = DateFormat('HH:mm').format(endTime.value);

    isLoading.value = false;
    update();
  }

  getAllUser() async {
    await FireStoreUtils.getAllUser().then((value) {
      if (value != null) {
        allUserList.value = value;
      }
    });
    await FireStoreUtils.getAllUserVehicle().then((value) {
      if (value != null) {
        allUserVehicle.value = value;
      }
    });
    selectedUserVehicleModel.value = UserVehicleModel();
    // await FireStoreUtils.getUserVehicle(selectedUserModel.value.id)
    //     .then((value) {
    //       print("selectedUser ${selectedUserModel.value.id}");
    //   if (value != null) {
    //     userVehicle.value = value;
    //   }
    // });
  }

  getParkingDetails() async {
    await FireStoreUtils.getParkingDetails(parkingModel.value.id.toString())
        .then((value) {
      if (value != null) {
        parkingModel.value = value;
      }
    });
  }

  calculateParkingAmount() {
    return double.parse(parkingModel.value.perHrPrice.toString()) *
        selectedDuration.value;
  }

  String calculateDuration(String? startTime, String? endTime) {
    if (startTime != null &&
        startTime.isNotEmpty &&
        endTime != null &&
        endTime.isNotEmpty) {
      return DateTime(
              DateTime.now().year,
              DateTime.now().month,
              DateTime.now().day,
              int.parse(endTime.split(":").first),
              int.parse(endTime.split(":").last))
          .difference(DateTime(
              DateTime.now().year,
              DateTime.now().month,
              DateTime.now().day,
              int.parse(startTime.split(":").first),
              int.parse(startTime.split(":").last)))
          .inHours
          .toString();
    } else {
      return "";
    }
  }

  RxList<OrderModel> selectedOrderModel = <OrderModel>[].obs;

  getBookedParking() async {
    await FireStoreUtils.getOrder(
            orderModel.value.bookingDate!,
            orderModel.value.bookingStartTime!,
            orderModel.value.bookingEndTime!,
            orderModel.value.parkingId.toString())
        .then((value) {
      if (value != null) {
        for (var element in value) {
          OrderModel orderModel1 = element;
          if (orderModel1.bookingStartTime!
                  .toDate()
                  .isBefore(orderModel.value.bookingStartTime!.toDate()) &&
              orderModel1.bookingEndTime!
                  .toDate()
                  .isAfter(orderModel.value.bookingStartTime!.toDate())) {
            log("parking ===>${orderModel1.parkingSlotId}");
            selectedOrderModel.add(orderModel1);
          } else if (orderModel.value.bookingStartTime!
              .toDate()
              .isAtSameMomentAs(orderModel1.bookingStartTime!.toDate())) {
            selectedOrderModel.add(orderModel1);
            log("parking ===>4 ${orderModel1.parkingSlotId}");
          } else if (orderModel.value.bookingStartTime!
              .toDate()
              .isBefore(orderModel1.bookingStartTime!.toDate())) {
            if (orderModel.value.bookingEndTime!
                .toDate()
                .isAfter(orderModel1.bookingEndTime!.toDate())) {
              selectedOrderModel.add(orderModel1);
              log("parking ===>2 ${orderModel1.parkingSlotId}");
            } else if (orderModel.value.bookingEndTime!
                .toDate()
                .isAtSameMomentAs(orderModel1.bookingEndTime!.toDate())) {
              selectedOrderModel.add(orderModel1);
              log("parking ===>2 ${orderModel1.parkingSlotId}");
            } else if (orderModel.value.bookingEndTime!
                    .toDate()
                    .isBefore(orderModel1.bookingEndTime!.toDate()) &&
                orderModel.value.bookingEndTime!
                    .toDate()
                    .isAfter(orderModel1.bookingStartTime!.toDate())) {
              selectedOrderModel.add(orderModel1);
              log("parking ===>3 ${orderModel1.parkingSlotId}");
            } else {
              log("parking ===>2 else");
            }
          } else {
            log("parking ===>1 else");
          }
        }
      }
    });
  }
}
