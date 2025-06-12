import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:watchman/constant/constant.dart';
import 'package:watchman/constant/show_toast_dialog.dart';
import 'package:watchman/model/order_model.dart';
import 'package:watchman/model/parking_model.dart';
import 'package:watchman/model/user_model.dart';
import 'package:watchman/model/wallet_transaction_model.dart';
import 'package:watchman/utils/fire_store_utils.dart';

class MyParkingBookingController extends GetxController {
  RxBool isLoading = true.obs;

  Rx<ParkingModel> selectedParkingModel = ParkingModel().obs;
  Rx<DateTime> selectedDateTime =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
          .obs;
  RxList<ParkingModel> parkingList = <ParkingModel>[].obs;
  Rx<UserModel> userModel = UserModel().obs;
  RxString totalTime = ''.obs;
  var orderSearchList = <OrderModel>[].obs;
  var orderModel = <OrderModel>[].obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getData();
    super.onInit();
  }

  RxInt selectedTabIndex = 0.obs;

  getData() async {
    await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid())
        .then((value) {
      if (value != null) {
        userModel.value = value;
      }
    });
    // await FireStoreUtils.getWatchMen(FirebaseAuth.instance.currentUser!.uid).then((user) async {
    //   await FireStoreUtils.getMyParkingList(user!.parkingId!.toString()).then((value) {
    //     if (value != null) {
    //       parkingList.value = value;
    //       if (parkingList.isNotEmpty) {
    //         selectedParkingModel.value = parkingList.first;
    //       }
    //       print("selectedParkingModel${selectedParkingModel.value.id}");
    //     }
    //   });
    // });

    if (userModel.value.parkingId != null) {
      await FireStoreUtils.getMyParking(parkingId: userModel.value.parkingId)
          .then((value) {
        if (value != null) {
          selectedParkingModel.value = value;
        }
      });
    }

    isLoading.value = false;
    update();
  }

  String calculateDuration(Timestamp bookingStartTime, Timestamp parkingOutTime) {
    DateTime start = bookingStartTime.toDate();
    DateTime end = parkingOutTime.toDate();

    double durationInHours = end.difference(start).inMinutes / 60.0;

    return "${durationInHours.toStringAsFixed(1)} hours";
  }

  confirmPayment(OrderModel orderModel) async {
    UserModel? userModel = await FireStoreUtils.getUserProfile(
        orderModel.parkingDetails!.userId.toString());
    RxDouble couponAmount = 0.0.obs;
    ShowToastDialog.showLoader("Please wait..");
    if (orderModel.coupon != null) {
      if (orderModel.coupon!.id != null) {
        if (orderModel.coupon!.type == "fix") {
          couponAmount.value =
              double.parse(orderModel.coupon!.amount.toString());
        } else {
          couponAmount.value = double.parse(orderModel.subTotal.toString()) *
              double.parse(orderModel.coupon!.amount.toString()) /
              100;
        }
      }
    }
    orderModel.paymentCompleted = true;

    if (userModel!.adminCommission != null &&
        userModel.adminCommission!.toJson().isNotEmpty &&
        userModel.adminCommission!.toJson().values.any((element) => element != null)) {
      orderModel.adminCommission = userModel.adminCommission;
    } else {
      orderModel.adminCommission = Constant.adminCommission;
    }

    WalletTransactionModel adminCommissionWallet = WalletTransactionModel(
        id: Constant.getUuid(),
        amount:
            "-${Constant.calculateAdminCommission(amount: (double.parse(orderModel.subTotal.toString()) - double.parse(couponAmount.toString())).toString(), adminCommission: orderModel.adminCommission)}",
        createdDate: Timestamp.now(),
        paymentType: orderModel.paymentType.toString(),
        transactionId: orderModel.id,
        isCredit: false,
        userId: orderModel.parkingDetails!.userId.toString(),
        note: "Admin commission debited");

    await FireStoreUtils.setWalletTransaction(adminCommissionWallet)
        .then((value) async {
      if (value == true) {
        await FireStoreUtils.updateOtherUserWallet(
          amount:
              "-${Constant.calculateAdminCommission(amount: (double.parse(orderModel.subTotal.toString()) - double.parse(couponAmount.toString())).toString(), adminCommission: orderModel.adminCommission)}",
          id: orderModel.parkingDetails!.userId.toString(),
        );
      }
    });

    await FireStoreUtils.setOrder(orderModel).then((value) {
      if (value == true) {
        ShowToastDialog.closeLoader();
      }
    });
  }
}
