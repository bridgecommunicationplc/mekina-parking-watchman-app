import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:watchman/constant/collection_name.dart';
import 'package:watchman/constant/constant.dart';
import 'package:watchman/constant/send_notification.dart';
import 'package:watchman/constant/show_toast_dialog.dart';
import 'package:watchman/controller/my_parking_booking_controller.dart';
import 'package:watchman/model/order_model.dart';
import 'package:watchman/model/user_model.dart';
import 'package:watchman/model/wallet_transaction_model.dart';
import 'package:watchman/themes/app_them_data.dart';
import 'package:watchman/themes/common_ui.dart';
import 'package:watchman/themes/round_button_fill.dart';
import 'package:watchman/ui/booking_process/payment_select_screen.dart';
import 'package:watchman/ui/parking/my_summery_screen.dart';
import 'package:watchman/ui/qr_code_scan_screen/qr_code_scan_screen.dart';
import 'package:watchman/utils/dark_theme_provider.dart';
import 'package:watchman/utils/fire_store_utils.dart';

class MyParkingBooingScreen extends StatelessWidget {
  final bool isBack;

  const MyParkingBooingScreen({required this.isBack, super.key});

  @override
  Widget build(BuildContext context) {
    double extraDurationInHours = 0.0;
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: MyParkingBookingController(),
        builder: (controller) {
          return Scaffold(
            appBar: UiInterface().customAppBar(
              isBack: isBack,
              context,
              themeChange,
              controller.selectedParkingModel.value.id != null
                  ? controller.selectedParkingModel.value.name.toString().tr
                  : "My Booking List".tr,
              actions: [
                InkWell(
                  onTap: () {
                    Get.to(const QrCodeScanScreen());
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Icon(Icons.qr_code_scanner,
                        color: themeChange.getThem()
                            ? AppThemData.grey01
                            : AppThemData.grey08),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
              ],
            ),
            body: controller.isLoading.value
                ? Constant.loader()
                : controller.selectedParkingModel.value.id == null
                    ? Constant.showEmptyView(
                        message:
                            "Parking not assign please contact to parking owner.")
                    : DefaultTabController(
                        length: 3,
                        child: Column(
                          children: [
                            Container(
                              color: themeChange.getThem()
                                  ? AppThemData.grey09
                                  : AppThemData.white,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Text(
                                    //   "Your Parking : ${controller.selectedParkingModel.value.name.toString().tr}",
                                    //   textAlign: TextAlign.center,
                                    //   style: TextStyle(
                                    //     color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey10,
                                    //     fontSize: 20,
                                    //     fontFamily: AppThemData.semiBold,
                                    //     fontWeight: FontWeight.w400,
                                    //   ),
                                    // ),
                                    // const SizedBox(
                                    //   height: 10,
                                    // ),
                                    DatePicker(
                                      DateTime.now(),
                                      height: 95,
                                      width: 76,
                                      initialSelectedDate:
                                          controller.selectedDateTime.value,
                                      selectionColor: AppThemData.primary07,
                                      selectedTextColor: AppThemData.primary11,
                                      onDateChange: (date) {
                                        controller.selectedDateTime.value =
                                            date;
                                      },
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    controller.selectedTabIndex.value == 0
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                                left: 0,
                                                top: 10,
                                                right: 8,
                                                bottom: 10),
                                            child: SizedBox(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: TextFormField(
                                                textInputAction:
                                                    TextInputAction.next,
                                                onChanged: (value) {
                                                  onSearchTextChanged(
                                                      value, controller);
                                                },
                                                decoration: InputDecoration(
                                                  hintText: 'Search...'.tr,
                                                  contentPadding:
                                                      const EdgeInsets.only(
                                                          left: 10,
                                                          right: 10,
                                                          top: 10),
                                                  hintStyle: const TextStyle(
                                                      color: Color(0XFF8A8989)),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0),
                                                          borderSide:
                                                              const BorderSide(
                                                                  color:
                                                                      AppThemData
                                                                          .grey04,
                                                                  width: 2.0)),
                                                  errorBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .error),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                  focusedErrorBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .error),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors
                                                            .grey.shade200),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                    TabBar(
                                      onTap: (value) {
                                        controller.selectedTabIndex.value =
                                            value;
                                        controller.update();
                                      },
                                      labelStyle: const TextStyle(
                                          fontFamily: AppThemData.semiBold),
                                      labelColor: themeChange.getThem()
                                          ? AppThemData.primary06
                                          : AppThemData.grey10,
                                      unselectedLabelStyle: const TextStyle(
                                          fontFamily: AppThemData.medium),
                                      unselectedLabelColor:
                                          themeChange.getThem()
                                              ? AppThemData.grey11
                                              : AppThemData.grey06,
                                      indicatorColor: AppThemData.primary06,
                                      indicatorWeight: 1,
                                      tabs: [
                                        Tab(
                                          text: "ongoing".tr,
                                        ),
                                        Tab(
                                          text: "completed".tr,
                                        ),
                                        // Tab(
                                        //   text: "canceled".tr,
                                        // ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: TabBarView(
                                children: [
                                  StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection(
                                            CollectionName.bookedParkingOrder)
                                        .where('status', whereIn: [
                                          Constant.placed,
                                          Constant.onGoing
                                        ])
                                        .where('bookingDate',
                                            isEqualTo: Timestamp.fromDate(
                                                controller
                                                    .selectedDateTime.value))
                                        .where('parkingId',
                                            isEqualTo: controller
                                                .selectedParkingModel.value.id)
                                        .orderBy('createdAt', descending: true)
                                        .snapshots(),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<QuerySnapshot> snapshot) {
                                      if (snapshot.hasError) {
                                        return Center(
                                            child: Text(
                                                'Something went wrong'.tr));
                                      }
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Constant.loader();
                                      }
                                      controller.orderModel.assignAll(
                                        snapshot.data!.docs.map((doc) {
                                          return OrderModel.fromJson(doc.data()
                                              as Map<String, dynamic>);
                                        }).toList(),
                                      );
                                      controller.orderSearchList
                                          .assignAll(controller.orderModel);

                                      return snapshot.data!.docs.isEmpty
                                          ? Constant.showEmptyView(
                                              message:
                                                  "No active rides found".tr)
                                          : Obx(() {
                                              if (controller
                                                  .orderSearchList.isEmpty) {
                                                return const Center(
                                                    child: Text(
                                                        "No matching results found"));
                                              } else {
                                                // snapshot.data!.docs.isEmpty
                                                //     ? Constant.showEmptyView(
                                                //     message:
                                                //     "No active booking found".tr)
                                                // : controller.orderSearchList.isEmpty
                                                // ? Center(
                                                // child: Text(
                                                //     "No matching results found"))
                                                // :
                                                return ListView.builder(
                                                    // itemCount: snapshot
                                                    //     .data!.docs.length,
                                                    itemCount: controller
                                                        .orderSearchList.length,
                                                    scrollDirection:
                                                        Axis.vertical,
                                                    shrinkWrap: true,
                                                    itemBuilder:
                                                        (context, index) {
                                                      OrderModel orderModel =
                                                          controller
                                                                  .orderSearchList[
                                                              index];
                                                      // OrderModel.fromJson(
                                                      //     snapshot.data!
                                                      //             .docs[index]
                                                      //             .data()
                                                      //         as Map<String,
                                                      //             dynamic>);
                                                      print(orderModel
                                                          .bookingDate!
                                                          .toDate());
                                                      if (orderModel
                                                                  .parkingInTime !=
                                                              null &&
                                                          orderModel
                                                                  .parkingOutTime !=
                                                              null) {
                                                        DateTime inTime =
                                                            orderModel
                                                                .parkingInTime!
                                                                .toDate();
                                                        DateTime outTime =
                                                            orderModel
                                                                .parkingOutTime!
                                                                .toDate();
                                                        DateTime endTime =
                                                            orderModel
                                                                .bookingEndTime!
                                                                .toDate();

                                                        if (inTime != null) {
                                                          if (outTime.isAfter(
                                                              endTime)) {
                                                            Duration extraTime =
                                                                outTime
                                                                    .difference(
                                                                        endTime);
                                                            // extraDurationInHours +=
                                                            //     extraTime.inMinutes /
                                                            //         60;
                                                          }

                                                          controller
                                                                  .totalTime.value =
                                                              controller.calculateDuration(
                                                                  orderModel
                                                                      .bookingStartTime!,
                                                                  orderModel
                                                                      .parkingOutTime!);

                                                          // if (currentTime
                                                          //     .isAfter(endTime)) {
                                                          //   Duration difference =
                                                          //       currentTime
                                                          //           .difference(
                                                          //               endTime);
                                                          //   extraDurationInHours +=
                                                          //       difference.inMinutes /
                                                          //           60;
                                                          // }
                                                        }
                                                      }

                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 16,
                                                                vertical: 10),
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 20,
                                                                  horizontal:
                                                                      10),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                            color: themeChange
                                                                    .getThem()
                                                                ? AppThemData
                                                                    .grey10
                                                                : AppThemData
                                                                    .white,
                                                          ),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Expanded(
                                                                    child: Text(
                                                                      "ID: ${orderModel.id!.substring(0, 6)}"
                                                                          .tr,
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          fontFamily: AppThemData
                                                                              .semiBold,
                                                                          color: themeChange.getThem()
                                                                              ? AppThemData.grey01
                                                                              : AppThemData.grey08),
                                                                    ),
                                                                  ),
                                                                  Visibility(
                                                                    visible: orderModel
                                                                            .status ==
                                                                        Constant
                                                                            .placed,
                                                                    child:
                                                                        InkWell(
                                                                      onTap:
                                                                          () {
                                                                        Get.to(
                                                                            QrCodeScanScreen(
                                                                          orderId:
                                                                              orderModel.id,
                                                                        ));
                                                                      },
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            right:
                                                                                10),
                                                                        child: Icon(
                                                                            Icons
                                                                                .qr_code_scanner,
                                                                            color: themeChange.getThem()
                                                                                ? AppThemData.blueLight
                                                                                : AppThemData.blueLight),
                                                                      ),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 10,
                                                              ),
                                                              const Divider(
                                                                  thickness: 1,
                                                                  color: AppThemData
                                                                      .grey04),
                                                              const SizedBox(
                                                                height: 10,
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Expanded(
                                                                    child: Row(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        const Icon(
                                                                            Icons
                                                                                .calendar_today,
                                                                            color:
                                                                                AppThemData.grey07,
                                                                            size: 20),
                                                                        const SizedBox(
                                                                          width:
                                                                              10,
                                                                        ),
                                                                        Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text(
                                                                              Constant.timestampToDate(orderModel.bookingDate!),
                                                                              style: TextStyle(
                                                                                color: themeChange.getThem() ? AppThemData.grey06 : AppThemData.grey09,
                                                                                fontSize: 16,
                                                                                fontFamily: AppThemData.medium,
                                                                              ),
                                                                            ),
                                                                            const SizedBox(
                                                                              height: 5,
                                                                            ),
                                                                            Text(
                                                                              "${Constant.timestampToTime(orderModel.bookingStartTime!)} - ${Constant.timestampToTime(orderModel.bookingEndTime!)}",
                                                                              style: const TextStyle(
                                                                                color: AppThemData.grey07,
                                                                                fontSize: 12,
                                                                                fontFamily: AppThemData.regular,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    child: Row(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        const Icon(
                                                                            Icons
                                                                                .local_parking,
                                                                            color:
                                                                                AppThemData.grey07,
                                                                            size: 20),
                                                                        const SizedBox(
                                                                          width:
                                                                              10,
                                                                        ),
                                                                        Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text(
                                                                              orderModel.parkingSlotId.toString(),
                                                                              style: TextStyle(
                                                                                color: themeChange.getThem() ? AppThemData.grey06 : AppThemData.grey09,
                                                                                fontSize: 16,
                                                                                fontFamily: AppThemData.medium,
                                                                              ),
                                                                            ),
                                                                            const SizedBox(
                                                                              height: 5,
                                                                            ),
                                                                            Text(
                                                                              "Parking Slot".tr,
                                                                              style: const TextStyle(
                                                                                color: AppThemData.grey07,
                                                                                fontSize: 12,
                                                                                fontFamily: AppThemData.regular,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 10,
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Expanded(
                                                                    child: Row(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        SvgPicture.asset(
                                                                            "assets/icon/ic_car_image.svg",
                                                                            height:
                                                                                24,
                                                                            width:
                                                                                24),
                                                                        const SizedBox(
                                                                          width:
                                                                              10,
                                                                        ),
                                                                        Expanded(
                                                                          child:
                                                                              Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Text(
                                                                                "${orderModel.bookedBy == "Watchman" || orderModel.bookedBy == "Owner" ? "" : orderModel.userVehicle!.vehicleModel!.name.toString()}(${(orderModel.bookedBy == "Watchman" || orderModel.bookedBy == "Owner") ? orderModel.vehicleNumberPlate.toString() : orderModel.userVehicle!.vehicleNumber.toString()})",
                                                                                style: TextStyle(
                                                                                  color: themeChange.getThem() ? AppThemData.grey06 : AppThemData.grey09,
                                                                                  fontSize: 16,
                                                                                  fontFamily: AppThemData.medium,
                                                                                ),
                                                                              ),
                                                                              const SizedBox(
                                                                                height: 5,
                                                                              ),
                                                                              Text(
                                                                                "vehicle Detail".tr,
                                                                                style: const TextStyle(
                                                                                  color: AppThemData.grey07,
                                                                                  fontSize: 12,
                                                                                  fontFamily: AppThemData.regular,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    child: Row(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        const Icon(
                                                                            Icons
                                                                                .access_time_rounded,
                                                                            color:
                                                                                AppThemData.grey07,
                                                                            size: 20),
                                                                        const SizedBox(
                                                                          width:
                                                                              10,
                                                                        ),
                                                                        Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text(
                                                                              "${orderModel.duration.toString()} hours".tr,
                                                                              style: TextStyle(
                                                                                color: themeChange.getThem() ? AppThemData.grey06 : AppThemData.grey09,
                                                                                fontSize: 16,
                                                                                fontFamily: AppThemData.medium,
                                                                              ),
                                                                            ),
                                                                            const SizedBox(
                                                                              height: 5,
                                                                            ),
                                                                            Text(
                                                                              "Time Durations".tr,
                                                                              style: const TextStyle(
                                                                                color: AppThemData.grey07,
                                                                                fontSize: 12,
                                                                                fontFamily: AppThemData.regular,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                              orderModel.bookedBy ==
                                                                          "Watchman" ||
                                                                      orderModel
                                                                              .bookedBy ==
                                                                          "Owner"
                                                                  ? const SizedBox(
                                                                      height:
                                                                          10,
                                                                    )
                                                                  : const SizedBox
                                                                      .shrink(),
                                                              orderModel.bookedBy ==
                                                                          "Watchman" ||
                                                                      orderModel
                                                                              .bookedBy ==
                                                                          "Owner"
                                                                  ? Row(
                                                                      children: [
                                                                        Expanded(
                                                                          child:
                                                                              Row(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              SvgPicture.asset("assets/icon/ic_user.svg", height: 24, width: 24),
                                                                              const SizedBox(
                                                                                width: 10,
                                                                              ),
                                                                              Expanded(
                                                                                child: Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Text(
                                                                                      orderModel.customerName.toString(),
                                                                                      style: TextStyle(
                                                                                        color: themeChange.getThem() ? AppThemData.grey06 : AppThemData.grey09,
                                                                                        fontSize: 16,
                                                                                        fontFamily: AppThemData.medium,
                                                                                      ),
                                                                                    ),
                                                                                    const SizedBox(
                                                                                      height: 5,
                                                                                    ),
                                                                                    Text(
                                                                                      "Customer Name".tr,
                                                                                      style: const TextStyle(
                                                                                        color: AppThemData.grey07,
                                                                                        fontSize: 12,
                                                                                        fontFamily: AppThemData.regular,
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        Expanded(
                                                                          child:
                                                                              Row(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              const Icon(Icons.call, color: AppThemData.grey07, size: 20),
                                                                              const SizedBox(
                                                                                width: 10,
                                                                              ),
                                                                              Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Text(
                                                                                    orderModel.customerPhoneNumber.toString().tr,
                                                                                    style: TextStyle(
                                                                                      color: themeChange.getThem() ? AppThemData.grey06 : AppThemData.grey09,
                                                                                      fontSize: 16,
                                                                                      fontFamily: AppThemData.medium,
                                                                                    ),
                                                                                  ),
                                                                                  const SizedBox(
                                                                                    height: 5,
                                                                                  ),
                                                                                  Text(
                                                                                    "Phone Number".tr,
                                                                                    style: const TextStyle(
                                                                                      color: AppThemData.grey07,
                                                                                      fontSize: 12,
                                                                                      fontFamily: AppThemData.regular,
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        )
                                                                      ],
                                                                    )
                                                                  : const SizedBox
                                                                      .shrink(),
                                                              orderModel.isParkingLeave ==
                                                                          true &&
                                                                      orderModel
                                                                              .isParkingLeave !=
                                                                          null
                                                                  ? const SizedBox(
                                                                      height:
                                                                          10,
                                                                    )
                                                                  : const SizedBox
                                                                      .shrink(),
                                                              orderModel.isParkingLeave ==
                                                                          true &&
                                                                      orderModel
                                                                              .isParkingLeave !=
                                                                          null
                                                                  ? Row(
                                                                      children: [
                                                                        Expanded(
                                                                          child:
                                                                              Row(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              const Icon(Icons.access_time_rounded, color: AppThemData.grey07, size: 20),
                                                                              const SizedBox(
                                                                                width: 10,
                                                                              ),
                                                                              Expanded(
                                                                                child: Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Text(
                                                                                      "Total Time",
                                                                                      style: TextStyle(
                                                                                        color: themeChange.getThem() ? AppThemData.grey06 : AppThemData.grey09,
                                                                                        fontSize: 16,
                                                                                        fontFamily: AppThemData.medium,
                                                                                      ),
                                                                                    ),
                                                                                    const SizedBox(
                                                                                      height: 5,
                                                                                    ),
                                                                                    Text(
                                                                                      controller.totalTime.value.tr,
                                                                                      style: const TextStyle(
                                                                                        color: AppThemData.grey07,
                                                                                        fontSize: 12,
                                                                                        fontFamily: AppThemData.regular,
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        Expanded(
                                                                            child:
                                                                                SizedBox.shrink())
                                                                      ],
                                                                    )
                                                                  : SizedBox
                                                                      .shrink(),
                                                              orderModel.extraTimeStart !=
                                                                          null &&
                                                                      orderModel
                                                                              .extraTimeEnd !=
                                                                          null
                                                                  ? const SizedBox(
                                                                      height:
                                                                          10,
                                                                    )
                                                                  : const SizedBox
                                                                      .shrink(),
                                                              orderModel.isExtraTimeRequestAccept ==
                                                                      true
                                                                  ? Row(
                                                                      children: [
                                                                        Expanded(
                                                                          child:
                                                                              Row(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              const Icon(Icons.calendar_today, color: AppThemData.grey07, size: 20),
                                                                              const SizedBox(
                                                                                width: 10,
                                                                              ),
                                                                              Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Text(
                                                                                    "${orderModel.extraTimeStart != null ? Constant.timestampToTime(orderModel.extraTimeStart!) : ""} - ${orderModel.extraTimeEnd != null ? Constant.timestampToTime(orderModel.extraTimeEnd!) : ""}",
                                                                                    style: TextStyle(
                                                                                      color: themeChange.getThem() ? AppThemData.grey06 : AppThemData.grey09,
                                                                                      fontSize: 13,
                                                                                      fontFamily: AppThemData.medium,
                                                                                    ),
                                                                                  ),
                                                                                  const SizedBox(
                                                                                    height: 5,
                                                                                  ),
                                                                                  Text(
                                                                                    "Extra Parking Time".tr,
                                                                                    style: const TextStyle(
                                                                                      color: AppThemData.grey07,
                                                                                      fontSize: 12,
                                                                                      fontFamily: AppThemData.regular,
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        Expanded(
                                                                          child:
                                                                              Row(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              const Icon(Icons.access_time_rounded, color: AppThemData.grey07, size: 20),
                                                                              const SizedBox(
                                                                                width: 10,
                                                                              ),
                                                                              Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Text(
                                                                                    "${double.parse(orderModel.extraTimeHours!).toStringAsFixed(1)} hours",
                                                                                    style: TextStyle(
                                                                                      color: themeChange.getThem() ? AppThemData.grey06 : AppThemData.grey09,
                                                                                      fontSize: 16,
                                                                                      fontFamily: AppThemData.medium,
                                                                                    ),
                                                                                  ),
                                                                                  const SizedBox(
                                                                                    height: 5,
                                                                                  ),
                                                                                  Text(
                                                                                    "Extra Parking Time".tr,
                                                                                    style: const TextStyle(
                                                                                      color: AppThemData.grey07,
                                                                                      fontSize: 12,
                                                                                      fontFamily: AppThemData.regular,
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    )
                                                                  : SizedBox
                                                                      .shrink(),
                                                              const SizedBox(
                                                                height: 12,
                                                              ),
                                                              // orderModel.isParkingLeave ==
                                                              //         true
                                                              //     ? extraDurationInHours >
                                                              //             0
                                                              //         ? Padding(
                                                              //             padding: EdgeInsets.only(
                                                              //                 left: 5,
                                                              //                 right:
                                                              //                     15,
                                                              //                 bottom:
                                                              //                     15),
                                                              //             child: Row(
                                                              //               crossAxisAlignment:
                                                              //                   CrossAxisAlignment
                                                              //                       .start,
                                                              //               children: [
                                                              //                 const Icon(
                                                              //                     Icons
                                                              //                         .calendar_today,
                                                              //                     color:
                                                              //                         AppThemData.grey07,
                                                              //                     size: 20),
                                                              //                 const SizedBox(
                                                              //                   width:
                                                              //                       10,
                                                              //                 ),
                                                              //                 Column(
                                                              //                   crossAxisAlignment:
                                                              //                       CrossAxisAlignment.start,
                                                              //                   children: [
                                                              //                     Text(
                                                              //                       "${orderModel.parkingInTime != null ? Constant.timestampToTime(orderModel.parkingInTime!) : ""} - ${orderModel.parkingOutTime != null ? Constant.timestampToTime(orderModel.parkingOutTime!) : ""}",
                                                              //                       style: TextStyle(
                                                              //                         color: themeChange.getThem() ? AppThemData.grey06 : AppThemData.grey09,
                                                              //                         fontSize: 13,
                                                              //                         fontFamily: AppThemData.medium,
                                                              //                       ),
                                                              //                     ),
                                                              //                     const SizedBox(
                                                              //                       height: 5,
                                                              //                     ),
                                                              //                     Text(
                                                              //                       "Parking Time".tr,
                                                              //                       style: const TextStyle(
                                                              //                         color: AppThemData.grey07,
                                                              //                         fontSize: 12,
                                                              //                         fontFamily: AppThemData.regular,
                                                              //                       ),
                                                              //                     ),
                                                              //                   ],
                                                              //                 ),
                                                              //               ],
                                                              //             ),
                                                              //           ),
                                                              //           Expanded(
                                                              //             child: Row(
                                                              //               crossAxisAlignment:
                                                              //                   CrossAxisAlignment
                                                              //                       .start,
                                                              //               children: [
                                                              //                 const Icon(
                                                              //                     Icons
                                                              //                         .access_time_rounded,
                                                              //                     color:
                                                              //                         AppThemData.grey07,
                                                              //                     size: 20),
                                                              //                 const SizedBox(
                                                              //                   width:
                                                              //                       10,
                                                              //                 ),
                                                              //                 Column(
                                                              //                   crossAxisAlignment:
                                                              //                       CrossAxisAlignment.start,
                                                              //                   children: [
                                                              //                     Text(
                                                              //                       "${extraDurationInHours.toStringAsFixed(1)} hours",
                                                              //                       style: TextStyle(
                                                              //                         color: themeChange.getThem() ? AppThemData.grey06 : AppThemData.grey09,
                                                              //                         fontSize: 16,
                                                              //                         fontFamily: AppThemData.medium,
                                                              //                       ),
                                                              //                     ),
                                                              //                     const SizedBox(
                                                              //                       height: 5,
                                                              //                     ),
                                                              //                     Text(
                                                              //                       "Extra Time".tr,
                                                              //                       style: const TextStyle(
                                                              //                         color: AppThemData.grey07,
                                                              //                         fontSize: 12,
                                                              //                         fontFamily: AppThemData.regular,
                                                              //                       ),
                                                              //                     ),
                                                              //                   ],
                                                              //                 ),
                                                              //               ],
                                                              //             ),
                                                              //           ),
                                                              //         ],
                                                              //       )
                                                              //     : const SizedBox.shrink(),
                                                              const SizedBox(
                                                                height: 8,
                                                              ),
                                                              // orderModel.isParkingLeave ==
                                                              //         true
                                                              //     ? Padding(
                                                              //         padding:
                                                              //             const EdgeInsets
                                                              //                 .only(
                                                              //                 left: 5,
                                                              //                 right:
                                                              //                     15,
                                                              //                 top: 10,
                                                              //                 bottom:
                                                              //                     15),
                                                              //         child: Row(
                                                              //           children: [
                                                              //             Expanded(
                                                              //               child:
                                                              //                   Text(
                                                              //                 'Extra Time Price (${extraDurationInHours.toStringAsFixed(2)}hours)'
                                                              //                     .tr,
                                                              //                 style:
                                                              //                     TextStyle(
                                                              //                   color: themeChange.getThem()
                                                              //                       ? AppThemData.grey03
                                                              //                       : AppThemData.grey07,
                                                              //                   fontSize:
                                                              //                       16,
                                                              //                   fontFamily:
                                                              //                       AppThemData.medium,
                                                              //                 ),
                                                              //               ),
                                                              //             ),
                                                              //             Text(
                                                              //               Constant.amountShow(
                                                              //                   amount: orderModel.perHrPrice != null && orderModel.perHrPrice!.isNotEmpty
                                                              //                       ? (double.parse(orderModel.perHrPrice.toString()) * extraDurationInHours).toStringAsFixed(2)
                                                              //                       : ""),
                                                              //               style:
                                                              //                   TextStyle(
                                                              //                 color: themeChange.getThem()
                                                              //                     ? AppThemData.grey03
                                                              //                     : AppThemData.grey07,
                                                              //                 fontSize:
                                                              //                     16,
                                                              //                 fontFamily:
                                                              //                     AppThemData.semiBold,
                                                              //               ),
                                                              //             ),
                                                              //           ],
                                                              //         ),
                                                              //       )
                                                              //     : const SizedBox
                                                              //         .shrink(),
                                                              Row(
                                                                children: [
                                                                  Expanded(
                                                                    child:
                                                                        RoundedButtonFill(
                                                                      title:
                                                                          "Summary"
                                                                              .tr,
                                                                      color: AppThemData
                                                                          .primary06,
                                                                      height:
                                                                          5.5,
                                                                      onPress:
                                                                          () {
                                                                        Get.to(
                                                                            () =>
                                                                                const MySummaryScreen(),
                                                                            arguments: {
                                                                              "orderModel": orderModel
                                                                            });
                                                                      },
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  // orderModel.paymentCompleted!=null &&  orderModel.paymentCompleted! ==
                                                                  //             true &&
                                                                  orderModel.status !=
                                                                          Constant
                                                                              .onGoing
                                                                      ? Expanded(
                                                                          child:
                                                                              RoundedButtonFill(
                                                                            title:
                                                                                "Active".tr,
                                                                            color:
                                                                                AppThemData.primary06,
                                                                            height:
                                                                                5.5,
                                                                            onPress:
                                                                                () async {
                                                                              ShowToastDialog.showLoader("Please wait".tr);
                                                                              orderModel.status = Constant.onGoing;
                                                                              orderModel.parkingInTime = Timestamp.now();
                                                                              await FireStoreUtils.setOrder(orderModel).then((value) {
                                                                                ShowToastDialog.showToast("Access Allowed");
                                                                                ShowToastDialog.closeLoader();
                                                                              });
                                                                            },
                                                                          ),
                                                                        )
                                                                      : const SizedBox
                                                                          .shrink(),
                                                                  orderModel.paymentCompleted !=
                                                                              null &&
                                                                          orderModel.paymentCompleted! ==
                                                                              true
                                                                      ? const SizedBox(
                                                                          width:
                                                                              10,
                                                                        )
                                                                      : SizedBox
                                                                          .shrink(),
                                                                  orderModel.paymentCompleted != null &&
                                                                          orderModel.paymentCompleted! ==
                                                                              false &&
                                                                          orderModel.paymentType.toString().toLowerCase() ==
                                                                              'cash'
                                                                                  .toLowerCase()
                                                                      ? const SizedBox(
                                                                          width:
                                                                              10,
                                                                        )
                                                                      : const SizedBox
                                                                          .shrink(),

                                                                  orderModel.status ==
                                                                      Constant.onGoing
                                                                      ? Expanded(
                                                                      child: orderModel.isParkingLeave != null && orderModel.isParkingLeave == true
                                                                          ?SizedBox.shrink()
                                                                      // orderModel.paymentCompleted != null && orderModel.paymentCompleted == true
                                                                      //     ? RoundedButtonFill(
                                                                      //   title: extraDurationInHours > 0 ? (orderModel.extraPaymentCompleted == true ? "Mark as Completed".tr : "Extra payment confirmed") : "Mark as Completed".tr,
                                                                      //   color: AppThemData.primary06,
                                                                      //   height: 5.5,
                                                                      //   fontSizes: extraDurationInHours > 0 && orderModel.extraPaymentCompleted == true ? 13 : 11.5,
                                                                      //   onPress: () async {
                                                                      //     if (extraDurationInHours > 0 || orderModel.extraPaymentCompleted == true) {
                                                                      //       ShowToastDialog.showLoader("Please wait".tr);
                                                                      //       orderModel.status = Constant.completed;
                                                                      //       await FireStoreUtils.setOrder(orderModel).then((value) {
                                                                      //         ShowToastDialog.closeLoader();
                                                                      //       });
                                                                      //     } else {
                                                                      //       RxDouble couponAmount = 0.0.obs;
                                                                      //       ShowToastDialog.showLoader("Please wait".tr);
                                                                      //       orderModel.extraPaymentCompleted = true;
                                                                      //       if (orderModel.coupon != null) {
                                                                      //         if (orderModel.coupon!.id != null) {
                                                                      //           if (orderModel.coupon!.type == "fix") {
                                                                      //             couponAmount.value = double.parse(orderModel.coupon!.amount.toString());
                                                                      //           } else {
                                                                      //             couponAmount.value = double.parse(orderModel.subTotal.toString()) * double.parse(orderModel.coupon!.amount.toString()) / 100;
                                                                      //           }
                                                                      //         }
                                                                      //       }
                                                                      //       UserModel? userModel = await FireStoreUtils.getUserProfile(orderModel.parkingDetails!.userId.toString());
                                                                      //
                                                                      //       if (userModel!.adminCommission != null && userModel.adminCommission!.toJson().isNotEmpty && userModel.adminCommission!.toJson().values.any((element) => element != null)) {
                                                                      //         orderModel.adminCommission = userModel.adminCommission;
                                                                      //       } else {
                                                                      //         orderModel.adminCommission = Constant.adminCommission;
                                                                      //       }
                                                                      //       WalletTransactionModel adminCommissionWallet = WalletTransactionModel(id: Constant.getUuid(), amount: "-${Constant.calculateAdminCommission(amount: ((double.parse(orderModel.perHrPrice.toString()) * extraDurationInHours) - double.parse(couponAmount.toString())).toString(), adminCommission: orderModel.adminCommission)}", createdDate: Timestamp.now(), paymentType: orderModel.paymentType.toString(), transactionId: orderModel.id, isCredit: false, userId: orderModel.parkingDetails!.userId.toString(), note: "Admin commission debited");
                                                                      //
                                                                      //       await FireStoreUtils.setWalletTransaction(adminCommissionWallet).then((value) async {
                                                                      //         if (value == true) {
                                                                      //           await FireStoreUtils.updateOtherUserWallet(
                                                                      //             amount: "-${Constant.calculateAdminCommission(amount: (double.parse(orderModel.subTotal.toString()) - double.parse(couponAmount.toString())).toString(), adminCommission: orderModel.adminCommission)}",
                                                                      //             id: orderModel.parkingDetails!.userId.toString(),
                                                                      //           );
                                                                      //         }
                                                                      //       });
                                                                      //       await FireStoreUtils.setOrder(orderModel).then((value) {
                                                                      //         ShowToastDialog.closeLoader();
                                                                      //       });
                                                                      //     }
                                                                      //   },
                                                                      // )
                                                                      //     : SizedBox.shrink()
                                                                      // RoundedButtonFill(
                                                                      //             title: "Confirm Payment",
                                                                      //             color: AppThemData.primary06,
                                                                      //             height: 5.5,
                                                                      //             fontSizes: 12,
                                                                      //             onPress: () async {
                                                                      //               ShowToastDialog.showLoader("Please wait".tr);
                                                                      //               String durationStr = controller.totalTime.value.toString().replaceAll(" hours", "");
                                                                      //               double duration = double.parse(durationStr);
                                                                      //               if(duration >= 1.0) {
                                                                      //                 orderModel.duration = durationStr;
                                                                      //                 String subTotal = (double.parse(orderModel.perHrPrice.toString()) * double.parse(duration.toString())).toString();
                                                                      //                 orderModel.subTotal = subTotal;
                                                                      //               }
                                                                      //
                                                                      //               await FireStoreUtils.setOrder(orderModel).then((value) {
                                                                      //                 ShowToastDialog.closeLoader();
                                                                      //               });
                                                                      //
                                                                      //               Get.to(() => PaymentSelectScreen(), arguments: {
                                                                      //                 "orderModel": orderModel
                                                                      //               });
                                                                      //             },
                                                                      //           )
                                                                          : RoundedButtonFill(
                                                                        title: "Parking Leave Confirmed".tr,
                                                                        color: AppThemData.primary06,
                                                                        height: 5.5,
                                                                        fontSizes: 12,
                                                                        onPress: () async {
                                                                          if (orderModel.isParkingLeave == null) {
                                                                            ShowToastDialog.showLoader("Please wait".tr);
                                                                            orderModel.parkingOutTime = Timestamp.now();
                                                                            orderModel.isParkingLeave = true;
                                                                            UserModel? receiverUserModel = await FireStoreUtils.getUserProfile(orderModel.parkingDetails!.userId.toString());

                                                                            UserModel? userModel = await FireStoreUtils.getUserProfile(orderModel.userId.toString());
                                                                            Map<String, dynamic> playLoad = <String, dynamic>{
                                                                              "type": "order",
                                                                              "orderId": orderModel.id
                                                                            };
                                                                            await SendNotification.sendOneNotification(token: receiverUserModel!.fcmToken.toString(), title: 'Parking Update', body: 'Customer Left the parkings area', payload: playLoad);

                                                                            await FireStoreUtils.getWatchmanNotification(orderModel.parkingDetails!.id.toString(), orderModel.parkingDetails!.userId.toString()).then((value) async {
                                                                              if (value != null) {
                                                                                await SendNotification.sendOneNotification(token: value.fcmToken.toString(), title: 'Parking Update', body: 'Customer Left the parkings area', payload: playLoad);
                                                                              }
                                                                            });

                                                                            String durationStr = controller.totalTime.value.toString().replaceAll(" hours", "");
                                                                            if (durationStr.isNotEmpty && double.tryParse(durationStr) != null) {
                                                                              double duration = double.parse(durationStr);
                                                                              if (duration >= 1.0) {
                                                                                orderModel.duration = durationStr;
                                                                                orderModel.subTotal = (double.parse(orderModel.perHrPrice.toString()) * duration).toString();
                                                                              }
                                                                            }
                                                                            Get.to(() => PaymentSelectScreen(), arguments: {
                                                                              "orderModel": orderModel
                                                                            });
                                                                            await FireStoreUtils.setOrder(orderModel).then((value) {
                                                                              ShowToastDialog.closeLoader();
                                                                            });
                                                                          }
                                                                        },
                                                                      ))
                                                                      : Container()
                                                                  // : orderModel.status ==
                                                                  //         Constant
                                                                  //             .onGoing
                                                                  //     ? Expanded(
                                                                  //         child:
                                                                  //             RoundedButtonFill(
                                                                  //         title: "Mark as Completed"
                                                                  //             .tr,
                                                                  //         color: AppThemData.primary06,
                                                                  //         height:
                                                                  //             5.5,
                                                                  //         onPress:
                                                                  //             () async {
                                                                  //           ShowToastDialog.showLoader(
                                                                  //               "Please wait".tr);
                                                                  //           orderModel.status =
                                                                  //               Constant.completed;
                                                                  //           orderModel.parkingOutTime =
                                                                  //               Timestamp.now();
                                                                  //           await FireStoreUtils.setOrder(orderModel)
                                                                  //               .then((value) {
                                                                  //             ShowToastDialog.closeLoader();
                                                                  //           });
                                                                  //         },
                                                                  //       ))
                                                                  //     : Container()
                                                                ],
                                                              ),
                                                              orderModel.isExtraTimeRequestAccept ==
                                                                      true
                                                                  ? const SizedBox
                                                                      .shrink()
                                                                  : Column(
                                                                      children: [
                                                                        orderModel.isExtraTimeApplied ==
                                                                                true
                                                                            ? Padding(
                                                                                padding: const EdgeInsets.only(top: 8.0, left: 5),
                                                                                child: Align(
                                                                                  alignment: Alignment.topLeft,
                                                                                  child: Text(
                                                                                    textAlign: TextAlign.start,
                                                                                    'Extra Parking Time Request'.tr,
                                                                                    style: const TextStyle(
                                                                                      color: Colors.black,
                                                                                      fontSize: 16,
                                                                                      fontFamily: AppThemData.medium,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              )
                                                                            : const SizedBox.shrink(),
                                                                        orderModel.isExtraTimeApplied ==
                                                                                true
                                                                            ? Padding(
                                                                                padding: const EdgeInsets.only(left: 5, right: 15, top: 10, bottom: 15),
                                                                                child: Row(
                                                                                  children: [
                                                                                    Expanded(
                                                                                      child: Text(
                                                                                        'Extra Parking Time(${double.parse(orderModel.extraTimeHours!).toStringAsFixed(2)}hours)'.tr,
                                                                                        style: TextStyle(
                                                                                          color: themeChange.getThem() ? AppThemData.grey03 : AppThemData.grey07,
                                                                                          fontSize: 16,
                                                                                          fontFamily: AppThemData.medium,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    Text(
                                                                                      Constant.amountShow(amount: orderModel.perHrPrice != null && orderModel.perHrPrice!.isNotEmpty ? (double.parse(orderModel.perHrPrice.toString()) * double.parse(orderModel.extraTimeHours!)).toStringAsFixed(2) : ""),
                                                                                      style: TextStyle(
                                                                                        color: themeChange.getThem() ? AppThemData.grey03 : AppThemData.grey07,
                                                                                        fontSize: 16,
                                                                                        fontFamily: AppThemData.semiBold,
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              )
                                                                            : const SizedBox.shrink(),
                                                                        orderModel.isExtraTimeApplied ==
                                                                                true
                                                                            ? Row(
                                                                                children: [
                                                                                  Expanded(
                                                                                    child: RoundedButtonFill(
                                                                                      title: "Reject",
                                                                                      color: AppThemData.primary06,
                                                                                      height: 5.5,
                                                                                      fontSizes: 14,
                                                                                      onPress: () async {
                                                                                        ShowToastDialog.showLoader("Please wait".tr);
                                                                                        orderModel.isExtraTimeApplied = false;
                                                                                        await FireStoreUtils.setOrder(orderModel).then((value) {
                                                                                          ShowToastDialog.closeLoader();
                                                                                        });
                                                                                        UserModel? userModel = await FireStoreUtils.getUserProfile(orderModel.userId.toString());
                                                                                        Map<String, dynamic> playLoad = <String, dynamic>{
                                                                                          "type": "order",
                                                                                          "orderId": orderModel.id
                                                                                        };
                                                                                        await SendNotification.sendOneNotification(token: userModel!.fcmToken.toString(), title: 'Parking Extension Denied!', body: 'We\'re sorry, but your request for extra parking time could not be approved.', payload: playLoad);
                                                                                        ShowToastDialog.showToast("Extra time request rejected");
                                                                                      },
                                                                                    ),
                                                                                  ),
                                                                                  const SizedBox(
                                                                                    width: 12,
                                                                                  ),
                                                                                  Expanded(
                                                                                    child: RoundedButtonFill(
                                                                                      title: "Accept",
                                                                                      color: AppThemData.primary06,
                                                                                      height: 5.5,
                                                                                      fontSizes: 14,
                                                                                      onPress: () async {
                                                                                        ShowToastDialog.showLoader("Please wait".tr);
                                                                                        orderModel.isExtraTimeRequestAccept = true;
                                                                                        await FireStoreUtils.setOrder(orderModel).then((value) {
                                                                                          ShowToastDialog.closeLoader();
                                                                                        });
                                                                                        UserModel? userModel = await FireStoreUtils.getUserProfile(orderModel.userId.toString());
                                                                                        Map<String, dynamic> playLoad = <String, dynamic>{
                                                                                          "type": "order",
                                                                                          "orderId": orderModel.id
                                                                                        };
                                                                                        await SendNotification.sendOneNotification(token: userModel!.fcmToken.toString(), title: 'Parking Time Extended!', body: 'Your request for extra parking time has been approved.', payload: playLoad);

                                                                                        ShowToastDialog.showToast("Extra time request accepted");
                                                                                      },
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              )
                                                                            : const SizedBox.shrink()
                                                                      ],
                                                                    )
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    });
                                              }
                                            });
                                    },
                                  ),
                                  StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection(
                                            CollectionName.bookedParkingOrder)
                                        .where('status',
                                            whereIn: [Constant.completed])
                                        .where('bookingDate',
                                            isEqualTo: Timestamp.fromDate(
                                                controller
                                                    .selectedDateTime.value))
                                        .where('parkingId',
                                            isEqualTo: controller
                                                .selectedParkingModel.value.id
                                                .toString())
                                        .orderBy("createdAt", descending: true)
                                        .snapshots(),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<QuerySnapshot> snapshot) {
                                      if (snapshot.hasError) {
                                        return Center(
                                            child: Text(
                                                'Something went wrong'.tr));
                                      }
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Constant.loader();
                                      }
                                      return snapshot.data!.docs.isEmpty
                                          ? Constant.showEmptyView(
                                              message:
                                                  "No Completed Booking Found")
                                          : ListView.builder(
                                              itemCount:
                                                  snapshot.data!.docs.length,
                                              scrollDirection: Axis.vertical,
                                              shrinkWrap: true,
                                              padding: EdgeInsets.zero,
                                              itemBuilder: (context, index) {
                                                OrderModel orderModel =
                                                    OrderModel.fromJson(snapshot
                                                            .data!.docs[index]
                                                            .data()
                                                        as Map<String,
                                                            dynamic>);
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 20,
                                                        horizontal: 10),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      color: themeChange
                                                              .getThem()
                                                          ? AppThemData.grey10
                                                          : AppThemData.white,
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                "ID: ${orderModel.id!.substring(0, 6)}"
                                                                    .tr,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontFamily:
                                                                        AppThemData
                                                                            .semiBold,
                                                                    color: themeChange.getThem()
                                                                        ? AppThemData
                                                                            .grey01
                                                                        : AppThemData
                                                                            .grey08),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        const Divider(
                                                            thickness: 1,
                                                            color: AppThemData
                                                                .grey04),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child: Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  const Icon(
                                                                      Icons
                                                                          .calendar_today,
                                                                      color: AppThemData
                                                                          .grey07,
                                                                      size: 20),
                                                                  const SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Column(
                                                                    children: [
                                                                      Text(
                                                                        Constant.timestampToDate(
                                                                            orderModel.bookingDate!),
                                                                        style:
                                                                            TextStyle(
                                                                          color: themeChange.getThem()
                                                                              ? AppThemData.grey06
                                                                              : AppThemData.grey09,
                                                                          fontSize:
                                                                              16,
                                                                          fontFamily:
                                                                              AppThemData.medium,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            5,
                                                                      ),
                                                                      Text(
                                                                        "${Constant.timestampToTime(orderModel.bookingStartTime!)} - ${Constant.timestampToTime(orderModel.bookingEndTime!)}",
                                                                        style:
                                                                            const TextStyle(
                                                                          color:
                                                                              AppThemData.grey07,
                                                                          fontSize:
                                                                              12,
                                                                          fontFamily:
                                                                              AppThemData.regular,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  const Icon(
                                                                      Icons
                                                                          .local_parking,
                                                                      color: AppThemData
                                                                          .grey07,
                                                                      size: 20),
                                                                  const SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        orderModel
                                                                            .parkingSlotId
                                                                            .toString(),
                                                                        style:
                                                                            TextStyle(
                                                                          color: themeChange.getThem()
                                                                              ? AppThemData.grey06
                                                                              : AppThemData.grey09,
                                                                          fontSize:
                                                                              16,
                                                                          fontFamily:
                                                                              AppThemData.medium,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            5,
                                                                      ),
                                                                      Text(
                                                                        "Parking Slot"
                                                                            .tr,
                                                                        style:
                                                                            const TextStyle(
                                                                          color:
                                                                              AppThemData.grey07,
                                                                          fontSize:
                                                                              12,
                                                                          fontFamily:
                                                                              AppThemData.regular,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child: Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  SvgPicture.asset(
                                                                      "assets/icon/ic_car_image.svg",
                                                                      height:
                                                                          24,
                                                                      width:
                                                                          24),
                                                                  const SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Expanded(
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          "${orderModel.bookedBy == "Watchman" || orderModel.bookedBy == "Owner" ? "" : orderModel.userVehicle!.vehicleModel!.name.toString()}(${(orderModel.bookedBy == "Watchman" || orderModel.bookedBy == "Owner") ? orderModel.vehicleNumberPlate.toString() : orderModel.userVehicle!.vehicleNumber.toString()})",
                                                                          style:
                                                                              TextStyle(
                                                                            color: themeChange.getThem()
                                                                                ? AppThemData.grey06
                                                                                : AppThemData.grey09,
                                                                            fontSize:
                                                                                16,
                                                                            fontFamily:
                                                                                AppThemData.medium,
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              5,
                                                                        ),
                                                                        Text(
                                                                          "vehicle Detail"
                                                                              .tr,
                                                                          style:
                                                                              const TextStyle(
                                                                            color:
                                                                                AppThemData.grey07,
                                                                            fontSize:
                                                                                12,
                                                                            fontFamily:
                                                                                AppThemData.regular,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  const Icon(
                                                                      Icons
                                                                          .access_time_rounded,
                                                                      color: AppThemData
                                                                          .grey07,
                                                                      size: 20),
                                                                  const SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        "${orderModel.duration.toString()} hours"
                                                                            .tr,
                                                                        style:
                                                                            TextStyle(
                                                                          color: themeChange.getThem()
                                                                              ? AppThemData.grey06
                                                                              : AppThemData.grey09,
                                                                          fontSize:
                                                                              16,
                                                                          fontFamily:
                                                                              AppThemData.medium,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            5,
                                                                      ),
                                                                      Text(
                                                                        "Time Durations"
                                                                            .tr,
                                                                        style:
                                                                            const TextStyle(
                                                                          color:
                                                                              AppThemData.grey07,
                                                                          fontSize:
                                                                              12,
                                                                          fontFamily:
                                                                              AppThemData.regular,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 20,
                                                        ),
                                                        RoundedButtonFill(
                                                          title: "Summary".tr,
                                                          color: AppThemData
                                                              .primary06,
                                                          height: 5.5,
                                                          onPress: () {
                                                            Get.to(
                                                                () =>
                                                                    const MySummaryScreen(),
                                                                arguments: {
                                                                  "orderModel":
                                                                      orderModel
                                                                });
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              });
                                    },
                                  ),
                                  // StreamBuilder<QuerySnapshot>(
                                  //   stream: FirebaseFirestore.instance
                                  //       .collection(
                                  //           CollectionName.bookedParkingOrder)
                                  //       .where('status',
                                  //           whereIn: [Constant.canceled])
                                  //       .where('bookingDate',
                                  //           isEqualTo: Timestamp.fromDate(
                                  //               controller
                                  //                   .selectedDateTime.value))
                                  //       .where('parkingId',
                                  //           isEqualTo: controller
                                  //               .selectedParkingModel.value.id
                                  //               .toString())
                                  //       .orderBy("createdAt", descending: true)
                                  //       .snapshots(),
                                  //   builder: (BuildContext context,
                                  //       AsyncSnapshot<QuerySnapshot> snapshot) {
                                  //     if (snapshot.hasError) {
                                  //       return Center(
                                  //           child: Text(
                                  //               'Something went wrong'.tr));
                                  //     }
                                  //     if (snapshot.connectionState ==
                                  //         ConnectionState.waiting) {
                                  //       return Constant.loader();
                                  //     }
                                  //     return snapshot.data!.docs.isEmpty
                                  //         ? Constant.showEmptyView(
                                  //             message:
                                  //                 "No Canceled Booking Found")
                                  //         : ListView.builder(
                                  //             itemCount:
                                  //                 snapshot.data!.docs.length,
                                  //             scrollDirection: Axis.vertical,
                                  //             shrinkWrap: true,
                                  //             itemBuilder: (context, index) {
                                  //               OrderModel orderModel =
                                  //                   OrderModel.fromJson(snapshot
                                  //                           .data!.docs[index]
                                  //                           .data()
                                  //                       as Map<String,
                                  //                           dynamic>);
                                  //               return Padding(
                                  //                 padding:
                                  //                     const EdgeInsets.all(8.0),
                                  //                 child: Container(
                                  //                   padding: const EdgeInsets
                                  //                       .symmetric(
                                  //                       vertical: 20,
                                  //                       horizontal: 10),
                                  //                   decoration: BoxDecoration(
                                  //                     borderRadius:
                                  //                         BorderRadius.circular(
                                  //                             12),
                                  //                     color: themeChange
                                  //                             .getThem()
                                  //                         ? AppThemData.grey10
                                  //                         : AppThemData.white,
                                  //                   ),
                                  //                   child: Column(
                                  //                     crossAxisAlignment:
                                  //                         CrossAxisAlignment
                                  //                             .start,
                                  //                     children: [
                                  //                       Row(
                                  //                         children: [
                                  //                           Expanded(
                                  //                             child: Text(
                                  //                               "ID: ${orderModel.id}"
                                  //                                   .tr,
                                  //                               style: TextStyle(
                                  //                                   fontSize:
                                  //                                       14,
                                  //                                   fontFamily:
                                  //                                       AppThemData
                                  //                                           .semiBold,
                                  //                                   color: themeChange.getThem()
                                  //                                       ? AppThemData
                                  //                                           .grey01
                                  //                                       : AppThemData
                                  //                                           .grey08),
                                  //                             ),
                                  //                           ),
                                  //                         ],
                                  //                       ),
                                  //                       const SizedBox(
                                  //                         height: 10,
                                  //                       ),
                                  //                       const Divider(
                                  //                           thickness: 1,
                                  //                           color: AppThemData
                                  //                               .grey04),
                                  //                       const SizedBox(
                                  //                         height: 10,
                                  //                       ),
                                  //                       Row(
                                  //                         children: [
                                  //                           Expanded(
                                  //                             child: Row(
                                  //                               crossAxisAlignment:
                                  //                                   CrossAxisAlignment
                                  //                                       .start,
                                  //                               children: [
                                  //                                 const Icon(
                                  //                                     Icons
                                  //                                         .calendar_today,
                                  //                                     color: AppThemData
                                  //                                         .grey07,
                                  //                                     size: 20),
                                  //                                 const SizedBox(
                                  //                                   width: 10,
                                  //                                 ),
                                  //                                 Column(
                                  //                                   children: [
                                  //                                     Text(
                                  //                                       Constant.timestampToDate(
                                  //                                           orderModel.bookingDate!),
                                  //                                       style:
                                  //                                           TextStyle(
                                  //                                         color: themeChange.getThem()
                                  //                                             ? AppThemData.grey06
                                  //                                             : AppThemData.grey09,
                                  //                                         fontSize:
                                  //                                             16,
                                  //                                         fontFamily:
                                  //                                             AppThemData.medium,
                                  //                                       ),
                                  //                                     ),
                                  //                                     const SizedBox(
                                  //                                       height:
                                  //                                           5,
                                  //                                     ),
                                  //                                     Text(
                                  //                                       "${Constant.timestampToTime(orderModel.bookingStartTime!)} - ${Constant.timestampToTime(orderModel.bookingEndTime!)}",
                                  //                                       style:
                                  //                                           const TextStyle(
                                  //                                         color:
                                  //                                             AppThemData.grey07,
                                  //                                         fontSize:
                                  //                                             12,
                                  //                                         fontFamily:
                                  //                                             AppThemData.regular,
                                  //                                       ),
                                  //                                     ),
                                  //                                   ],
                                  //                                 ),
                                  //                               ],
                                  //                             ),
                                  //                           ),
                                  //                           Expanded(
                                  //                             child: Row(
                                  //                               crossAxisAlignment:
                                  //                                   CrossAxisAlignment
                                  //                                       .start,
                                  //                               children: [
                                  //                                 const Icon(
                                  //                                     Icons
                                  //                                         .local_parking,
                                  //                                     color: AppThemData
                                  //                                         .grey07,
                                  //                                     size: 20),
                                  //                                 const SizedBox(
                                  //                                   width: 10,
                                  //                                 ),
                                  //                                 Column(
                                  //                                   crossAxisAlignment:
                                  //                                       CrossAxisAlignment
                                  //                                           .start,
                                  //                                   children: [
                                  //                                     Text(
                                  //                                       orderModel
                                  //                                           .parkingSlotId
                                  //                                           .toString(),
                                  //                                       style:
                                  //                                           TextStyle(
                                  //                                         color: themeChange.getThem()
                                  //                                             ? AppThemData.grey06
                                  //                                             : AppThemData.grey09,
                                  //                                         fontSize:
                                  //                                             16,
                                  //                                         fontFamily:
                                  //                                             AppThemData.medium,
                                  //                                       ),
                                  //                                     ),
                                  //                                     const SizedBox(
                                  //                                       height:
                                  //                                           5,
                                  //                                     ),
                                  //                                     Text(
                                  //                                       "Parking Slot"
                                  //                                           .tr,
                                  //                                       style:
                                  //                                           const TextStyle(
                                  //                                         color:
                                  //                                             AppThemData.grey07,
                                  //                                         fontSize:
                                  //                                             12,
                                  //                                         fontFamily:
                                  //                                             AppThemData.regular,
                                  //                                       ),
                                  //                                     ),
                                  //                                   ],
                                  //                                 ),
                                  //                               ],
                                  //                             ),
                                  //                           )
                                  //                         ],
                                  //                       ),
                                  //                       const SizedBox(
                                  //                         height: 10,
                                  //                       ),
                                  //                       Row(
                                  //                         children: [
                                  //                           Expanded(
                                  //                             child: Row(
                                  //                               crossAxisAlignment:
                                  //                                   CrossAxisAlignment
                                  //                                       .start,
                                  //                               children: [
                                  //                                 SvgPicture.asset(
                                  //                                     "assets/icon/ic_car_image.svg",
                                  //                                     height:
                                  //                                         24,
                                  //                                     width:
                                  //                                         24),
                                  //                                 const SizedBox(
                                  //                                   width: 10,
                                  //                                 ),
                                  //                                 Column(
                                  //                                   crossAxisAlignment:
                                  //                                       CrossAxisAlignment
                                  //                                           .start,
                                  //                                   children: [
                                  //                                     Text(
                                  //                                       orderModel
                                  //                                           .userVehicle!
                                  //                                           .vehicleModel!
                                  //                                           .name
                                  //                                           .toString(),
                                  //                                       style:
                                  //                                           TextStyle(
                                  //                                         color: themeChange.getThem()
                                  //                                             ? AppThemData.grey06
                                  //                                             : AppThemData.grey09,
                                  //                                         fontSize:
                                  //                                             16,
                                  //                                         fontFamily:
                                  //                                             AppThemData.medium,
                                  //                                       ),
                                  //                                     ),
                                  //                                     const SizedBox(
                                  //                                       height:
                                  //                                           5,
                                  //                                     ),
                                  //                                     Text(
                                  //                                       "vehicle Detail"
                                  //                                           .tr,
                                  //                                       style:
                                  //                                           const TextStyle(
                                  //                                         color:
                                  //                                             AppThemData.grey07,
                                  //                                         fontSize:
                                  //                                             12,
                                  //                                         fontFamily:
                                  //                                             AppThemData.regular,
                                  //                                       ),
                                  //                                     ),
                                  //                                   ],
                                  //                                 ),
                                  //                               ],
                                  //                             ),
                                  //                           ),
                                  //                           Expanded(
                                  //                             child: Row(
                                  //                               crossAxisAlignment:
                                  //                                   CrossAxisAlignment
                                  //                                       .start,
                                  //                               children: [
                                  //                                 const Icon(
                                  //                                     Icons
                                  //                                         .access_time_rounded,
                                  //                                     color: AppThemData
                                  //                                         .grey07,
                                  //                                     size: 20),
                                  //                                 const SizedBox(
                                  //                                   width: 10,
                                  //                                 ),
                                  //                                 Column(
                                  //                                   crossAxisAlignment:
                                  //                                       CrossAxisAlignment
                                  //                                           .start,
                                  //                                   children: [
                                  //                                     Text(
                                  //                                       "${orderModel.duration.toString()} hours"
                                  //                                           .tr,
                                  //                                       style:
                                  //                                           TextStyle(
                                  //                                         color: themeChange.getThem()
                                  //                                             ? AppThemData.grey06
                                  //                                             : AppThemData.grey09,
                                  //                                         fontSize:
                                  //                                             16,
                                  //                                         fontFamily:
                                  //                                             AppThemData.medium,
                                  //                                       ),
                                  //                                     ),
                                  //                                     const SizedBox(
                                  //                                       height:
                                  //                                           5,
                                  //                                     ),
                                  //                                     Text(
                                  //                                       "Time Durations"
                                  //                                           .tr,
                                  //                                       style:
                                  //                                           const TextStyle(
                                  //                                         color:
                                  //                                             AppThemData.grey07,
                                  //                                         fontSize:
                                  //                                             12,
                                  //                                         fontFamily:
                                  //                                             AppThemData.regular,
                                  //                                       ),
                                  //                                     ),
                                  //                                   ],
                                  //                                 ),
                                  //                               ],
                                  //                             ),
                                  //                           )
                                  //                         ],
                                  //                       )
                                  //                     ],
                                  //                   ),
                                  //                 ),
                                  //               );
                                  //             });
                                  //   },
                                  // ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
          );
        });
  }

  void onSearchTextChanged(String text, MyParkingBookingController controller) {
    if (text.isEmpty) {
      controller.orderSearchList.assignAll(controller.orderModel);
      print("Search Text is empty. Showing all orders.");
      return;
    }

    final filteredList = controller.orderModel.where((order) {
      final vehicleNumber = order.vehicleNumberPlate?.toLowerCase();
      final searchText = text.toLowerCase();

      print(
          "Checking Vehicle Number: $vehicleNumber against Search Text: $searchText");

      return vehicleNumber?.contains(searchText) ?? false;
    }).toList();

    controller.orderSearchList.assignAll(filteredList);

    print("Filtered List Length: ${controller.orderSearchList.length}");
  }
}
