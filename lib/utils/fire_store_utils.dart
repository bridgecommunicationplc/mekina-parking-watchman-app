import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:watchman/constant/collection_name.dart';
import 'package:watchman/constant/constant.dart';
import 'package:watchman/model/admin_commission.dart';
import 'package:watchman/model/faq_model.dart';
import 'package:watchman/model/language_model.dart';
import 'package:watchman/model/on_boarding_model.dart';
import 'package:watchman/model/order_model.dart';
import 'package:watchman/model/parking_model.dart';
import 'package:watchman/model/payment_method_model.dart';
import 'package:watchman/model/payment_transaction_model.dart';
import 'package:watchman/model/review_model.dart';
import 'package:watchman/model/tax_model.dart';
import 'package:watchman/model/user_model.dart';
import 'package:watchman/model/user_vehicle_model.dart';
import 'package:watchman/model/vehicle_brand_model.dart';
import 'package:watchman/model/vehicle_model.dart';
import 'package:watchman/model/wallet_transaction_model.dart';
import 'package:watchman/widgets/firebase_pagination/src/geoflutterfire.dart';
import 'package:watchman/widgets/firebase_pagination/src/models/point.dart';

class FireStoreUtils {
  static FirebaseFirestore fireStore = FirebaseFirestore.instance;

  static String getCurrentUid() {
    return FirebaseAuth.instance.currentUser!.uid;
  }

  static Future<bool> isLogin() async {
    bool isLogin = false;
    if (FirebaseAuth.instance.currentUser != null) {
      isLogin = await userExistOrNot(FirebaseAuth.instance.currentUser!.uid);
    } else {
      isLogin = false;
    }
    return isLogin;
  }

  static Future<bool> userExistOrNot(String uid) async {
    bool isExist = false;

    await fireStore.collection(CollectionName.users).doc(uid).get().then(
      (value) {
        if (value.exists) {
          isExist = true;
        } else {
          isExist = false;
        }
      },
    ).catchError((error) {
      log("Failed to check user exist: $error");
      isExist = false;
    });
    return isExist;
  }

  static Future<List<OnBoardingModel>> getOnBoardingList() async {
    List<OnBoardingModel> onBoardingModel = [];
    await fireStore.collection(CollectionName.onBoarding).get().then((value) {
      for (var element in value.docs) {
        OnBoardingModel documentModel =
            OnBoardingModel.fromJson(element.data());
        onBoardingModel.add(documentModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return onBoardingModel;
  }

  static Future<bool> updateWatchmen(UserModel watchModel) async {
    bool isUpdate = false;
    await fireStore
        .collection(CollectionName.users)
        .doc(watchModel.id)
        .set(watchModel.toJson())
        .whenComplete(() {
      isUpdate = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isUpdate = false;
    });
    return isUpdate;
  }

  static Future<UserModel?> getUserProfile(String uuid) async {
    UserModel? userModel;
    await fireStore
        .collection(CollectionName.users)
        .doc(uuid)
        .get()
        .then((value) {
      if (value.exists) {
        userModel = UserModel.fromJson(value.data()!);
      }
    }).catchError((error) {
      log("Failed to update user: $error");
      userModel = null;
    });
    return userModel;
  }

  static Future<UserModel?> getOwnerProfile(String uuid) async {
    UserModel? userModel;
    await fireStore
        .collection(CollectionName.users)
        .doc(uuid)
        .get()
        .then((value) {
      if (value.exists) {
        userModel = UserModel.fromJson(value.data()!);
      }
    }).catchError((error) {
      log("Failed to update user: $error");
      userModel = null;
    });
    return userModel;
  }

  static Future<UserModel?> getWatchMen(String uuid) async {
    UserModel? userModel;
    await fireStore
        .collection(CollectionName.users)
        .doc(uuid)
        .get()
        .then((value) {
      if (value.exists) {
        userModel = UserModel.fromJson(value.data()!);
      }
    }).catchError((error) {
      log("Failed to update user: $error");
      userModel = null;
    });
    return userModel;
  }

  Future<List<TaxModel>?> getTaxList() async {
    List<TaxModel> taxList = [];

    await fireStore
        .collection(CollectionName.tax)
        .where('country', isEqualTo: Constant.country)
        .where('enable', isEqualTo: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        TaxModel taxModel = TaxModel.fromJson(element.data());
        taxList.add(taxModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return taxList;
  }

  static Future<bool?> setPaymentTransaction(
      PaymentTransactionModel paymentTransactionModel) async {
    bool isAdded = false;
    await fireStore
        .collection(CollectionName.paymentTransaction)
        .doc(paymentTransactionModel.id)
        .set(paymentTransactionModel.toJson())
        .then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<List<PaymentTransactionModel>?> getPaymentTransaction() async {
    List<PaymentTransactionModel> paymentTransactionModel = [];

    await fireStore
        .collection(CollectionName.paymentTransaction)
        .where('userId', isEqualTo: FireStoreUtils.getCurrentUid())
        .orderBy('createdDate', descending: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        PaymentTransactionModel taxModel =
        PaymentTransactionModel.fromJson(element.data());
        paymentTransactionModel.add(taxModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return paymentTransactionModel;
  }

  static Future<List<VehicleBrandModel>?> gerBrand() async {
    List<VehicleBrandModel> brandList = [];

    await fireStore
        .collection(CollectionName.brand)
        .where("enable", isEqualTo: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        VehicleBrandModel taxModel = VehicleBrandModel.fromJson(element.data());
        brandList.add(taxModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return brandList;
  }

  static Future<List<UserVehicleModel>?> getUserVehicle() async {
    List<UserVehicleModel> userVehicleList = [];
    await fireStore
        .collection(CollectionName.userVehicles)
        .where("userId", isEqualTo: getCurrentUid())
        .get()
        .then((value) async {
      for (var element in value.docs) {
        UserVehicleModel facilitiesModel =
            UserVehicleModel.fromJson(element.data());
        userVehicleList.add(facilitiesModel);
      }
    });
    return userVehicleList;
  }

  static Future<bool> updateUserVehicle(
      UserVehicleModel userVehicleModel) async {
    bool isUpdate = false;
    await fireStore
        .collection(CollectionName.userVehicles)
        .doc(userVehicleModel.id)
        .set(userVehicleModel.toJson())
        .whenComplete(() {
      isUpdate = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isUpdate = false;
    });
    return isUpdate;
  }

  static Future<List<VehicleModel>?> getVehicleModel(String id) async {
    List<VehicleModel> vehicleModel = [];

    await fireStore
        .collection(CollectionName.model)
        .where("brandId", isEqualTo: id)
        .where("enable", isEqualTo: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        VehicleModel taxModel = VehicleModel.fromJson(element.data());
        vehicleModel.add(taxModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return vehicleModel;
  }

  Future<PaymentModel?> getPayment() async {
    PaymentModel? paymentModel;
    await fireStore
        .collection(CollectionName.settings)
        .doc("payment")
        .get()
        .then((value) {
      paymentModel = PaymentModel.fromJson(value.data()!);
    });
    return paymentModel;
  }

  static Future<void> updateNewUser(Map<String, dynamic> userData) async {
    try {
      String userId =
          userData['id'] ?? fireStore.collection(CollectionName.users).doc().id;
      await fireStore.collection(CollectionName.users).doc(userId).set(
            userData,
            SetOptions(merge: true),
          );
    } catch (e) {
      print("Error updating user: $e");
      throw e;
    }
  }

  static Future<ParkingModel?> getParkingDetails(String uuid) async {
    ParkingModel? slotModel;
    await fireStore
        .collection(CollectionName.parking)
        .doc(uuid)
        .get()
        .then((value) {
      if (value.exists) {
        slotModel = ParkingModel.fromJson(value.data()!);
      }
    }).catchError((error) {
      log("Failed to update user: $error");
      slotModel = null;
    });
    return slotModel;
  }

  static Future<UserModel?> getWatchmanNotification(
      String parkingId, String ownerId) async {
    UserModel? userModel;
    await fireStore
        .collection(CollectionName.users)
        .where("role", isEqualTo: "security")
        .where("parkingId", isEqualTo: parkingId)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        userModel = UserModel.fromJson(value.docs.first.data());
      }
    }).catchError((error) {
      log("Failed to update user: $error");
      userModel = null;
    });
    return userModel;
  }

  final geo = Geoflutterfire();
  StreamController<List<ParkingModel>>? getNearestOrderRequestController;

  Stream<List<ParkingModel>> getParkingNearest(
      {double? latitude, double? longLatitude}) async* {
    getNearestOrderRequestController =
        StreamController<List<ParkingModel>>.broadcast();
    List<ParkingModel> ordersList = [];
    var query = fireStore
        .collection(CollectionName.parking)
        .where("isEnable", isEqualTo: true);

    GeoFirePoint center =
        geo.point(latitude: latitude ?? 0.0, longitude: longLatitude ?? 0.0);
    Stream<List<DocumentSnapshot>> stream = geo
        .collection(collectionRef: query)
        .within(
            center: center,
            radius: double.parse(Constant.radius),
            field: 'position',
            strictMode: true);

    stream.listen((List<DocumentSnapshot> documentList) {
      ordersList.clear();
      for (var document in documentList) {
        final data = document.data() as Map<String, dynamic>;
        ParkingModel orderModel = ParkingModel.fromJson(data);

        ordersList.add(orderModel);
      }
      getNearestOrderRequestController!.sink.add(ordersList);
    });

    yield* getNearestOrderRequestController!.stream;
  }

  static Future<List<ParkingModel>?> getMyParkingList(String userId) async {
    List<ParkingModel> parkingList = [];
    await fireStore
        .collection(CollectionName.parking)
        .where("userId", isEqualTo: userId)
        .get()
        .then((value) async {
      for (var element in value.docs) {
        ParkingModel facilitiesModel = ParkingModel.fromJson(element.data());
        parkingList.add(facilitiesModel);
      }
    });
    return parkingList;
  }

  StreamController<List<ParkingModel>>? getNearestFilterParking;

  Stream<List<ParkingModel>> getFilterParking(
      {double? latitude,
      double? longLatitude,
      String? parkingType,
      String? distance}) async* {
    getNearestFilterParking = StreamController<List<ParkingModel>>.broadcast();
    List<ParkingModel> ordersList = [];

    var query = fireStore
        .collection(CollectionName.parking)
        .where("parkingType", isEqualTo: parkingType)
        .where("isEnable", isEqualTo: true);

    GeoFirePoint center =
        geo.point(latitude: latitude ?? 0.0, longitude: longLatitude ?? 0.0);
    Stream<List<DocumentSnapshot>> stream = geo
        .collection(collectionRef: query)
        .within(
            center: center,
            radius: double.parse(distance.toString()),
            field: 'position',
            strictMode: true);

    stream.listen((List<DocumentSnapshot> documentList) {
      ordersList.clear();
      for (var document in documentList) {
        final data = document.data() as Map<String, dynamic>;
        ParkingModel orderModel = ParkingModel.fromJson(data);

        ordersList.add(orderModel);
      }
      getNearestFilterParking!.sink.add(ordersList);
    });

    yield* getNearestFilterParking!.stream;
  }

  static Future<List<UserVehicleModel>?> getSubscriptionUserVehicle(
      userId) async {
    List<UserVehicleModel> userVehicleList = [];
    await fireStore
        .collection(CollectionName.userVehicles)
        .where("userId", isEqualTo: userId)
        .get()
        .then((value) async {
      for (var element in value.docs) {
        UserVehicleModel facilitiesModel =
            UserVehicleModel.fromJson(element.data());
        userVehicleList.add(facilitiesModel);
      }
    });
    return userVehicleList;
  }

  static Future<List<UserModel>> getSubscriptionUsers() async {
    List<UserModel> userList = [];
    await fireStore
        .collection(CollectionName.users)
        .where("role", isEqualTo: "customer")
        .where("subscriptions", isNotEqualTo: null)
        .get()
        .then((value) async {
      for (var element in value.docs) {
        UserModel userModel = UserModel.fromJson(element.data());
        if (userModel.subscriptions != null &&
            userModel.subscriptions!.isNotEmpty) {
          userList.add(userModel);
        }
      }
    });
    return userList;
  }

  static Future<List<UserModel>?> getUser(userId) async {
    List<UserModel> userList = [];
    await fireStore
        .collection(CollectionName.users)
        .where("id", isEqualTo: userId)
        .get()
        .then((value) async {
      for (var element in value.docs) {
        UserModel facilitiesModel = UserModel.fromJson(element.data());
        userList.add(facilitiesModel);
      }
    });
    return userList;
  }

  static Future<List<UserVehicleModel>> getAllUserVehicle() async {
    List<UserVehicleModel> userVehicleList = [];
    await fireStore
        .collection(CollectionName.userVehicles)
        .get()
        .then((value) async {
      for (var element in value.docs) {
        UserVehicleModel userVehicleModel =
            UserVehicleModel.fromJson(element.data());
        userVehicleList.add(userVehicleModel);
      }
    });
    return userVehicleList;
  }

  static Future<List<OrderModel>?> getOrder(Timestamp date, Timestamp startTime,
      Timestamp endTime, String parkingId) async {
    List<OrderModel> orderList = [];
    await fireStore
        .collection(CollectionName.bookedParkingOrder)
        .where(
          'parkingId',
          isEqualTo: parkingId,
        )
        .where('status', whereIn: [Constant.placed, Constant.onGoing])
        .where('bookingDate', isEqualTo: date)
        .get()
        .then((value) async {
          for (var element in value.docs) {
            OrderModel orderModel = OrderModel.fromJson(element.data());
            orderList.add(orderModel);
          }
        });
    return orderList;
  }

  static Future<List<UserModel>> getAllUser() async {
    List<UserModel> userList = [];
    await fireStore
        .collection(CollectionName.users)
        .where("role", isEqualTo: "customer")
        .get()
        .then((value) async {
      for (var element in value.docs) {
        UserModel userModel = UserModel.fromJson(element.data());
        userList.add(userModel);
      }
    });
    return userList;
  }

  static Future<List<LanguageModel>?> getLanguage() async {
    List<LanguageModel> languageList = [];

    await fireStore.collection(CollectionName.languages).get().then((value) {
      for (var element in value.docs) {
        LanguageModel taxModel = LanguageModel.fromJson(element.data());
        languageList.add(taxModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return languageList;
  }

  static Future<bool?> setWalletTransaction(
      WalletTransactionModel walletTransactionModel) async {
    bool isAdded = false;
    await fireStore
        .collection(CollectionName.walletTransaction)
        .doc(walletTransactionModel.id)
        .set(walletTransactionModel.toJson())
        .then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<bool?> updateOtherUserWallet(
      {required String amount, required String id}) async {
    bool isAdded = false;
    await getUserProfile(id).then((value) async {
      if (value != null) {
        UserModel userModel = value;
        userModel.walletAmount =
            (double.parse(userModel.walletAmount.toString()) +
                    double.parse(amount))
                .toString();
        await FireStoreUtils.updateWatchmen(userModel).then((value) {
          isAdded = value;
        });
      }
    });
    return isAdded;
  }

  static Future<bool?> deleteUser() async {
    bool? isDelete;
    try {
      await fireStore
          .collection(CollectionName.users)
          .doc(FireStoreUtils.getCurrentUid())
          .delete();

      // delete user  from firebase auth
      await FirebaseAuth.instance.currentUser!.delete().then((value) {
        isDelete = true;
      });
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return false;
    }
    return isDelete;
  }

  getSettings() async {
    fireStore
        .collection(CollectionName.settings)
        .doc("globalKey")
        .snapshots()
        .listen((event) {
      if (event.exists) {
        Constant.mapAPIKey = event.data()!["googleMapKey"];
        Constant.radius = event.data()!["radius"];
        Constant.distanceType = event.data()!["distanceType"];
      }
    });

    await fireStore
        .collection(CollectionName.settings)
        .doc("notification_setting")
        .get()
        .then((value) {
      if (value.exists) {
        Constant.senderId = value.data()!['senderId'].toString();
        Constant.jsonNotificationFileURL =
            value.data()!['serviceJson'].toString();
      }
    });

    await fireStore
        .collection(CollectionName.settings)
        .doc("global")
        .get()
        .then((value) {
      if (value.exists) {
        Constant.termsAndConditions = value.data()!["termsAndConditions"];
        Constant.privacyPolicy = value.data()!["privacyPolicy"];
        Constant.minimumAmountToDeposit =
            value.data()!["minimumAmountToDeposit"];
        Constant.minimumAmountToWithdrawal =
            value.data()!["minimumAmountToWithdrawal"];
        Constant.mapType = value.data()!["mapType"];
        Constant.selectedMapType = value.data()!["selectedMapType"];
      }
    });

    await fireStore
        .collection(CollectionName.settings)
        .doc("referral")
        .get()
        .then((value) {
      if (value.exists) {
        Constant.referralAmount = value.data()!["referralAmount"];
      }
    });

    await fireStore
        .collection(CollectionName.settings)
        .doc("contact_us")
        .get()
        .then((value) {
      if (value.exists) {
        Constant.supportURL = value.data()!["supportURL"];
      }
    });

    await fireStore
        .collection(CollectionName.settings)
        .doc("adminCommission")
        .get()
        .then((value) {
      Constant.adminCommission = AdminCommission.fromJson(value.data()!);
    });
  }

  static Future<OrderModel?> getSingleOrder(String orderId) async {
    OrderModel? orderModel;
    await fireStore
        .collection(CollectionName.bookedParkingOrder)
        .doc(orderId)
        .get()
        .then((value) {
      if (value.exists) {
        orderModel = OrderModel.fromJson(value.data()!);
      }
    }).catchError((error) {
      log("Failed to update user: $error");
      orderModel = null;
    });
    return orderModel;
  }

  static Future<ParkingModel?> getMyParking({parkingId}) async {
    ParkingModel? parkingModel;
    await fireStore
        .collection(CollectionName.parking)
        .doc(parkingId)
        .get()
        .then((value) async {
      parkingModel = ParkingModel.fromJson(value.data()!);
      print("parkingModel:: ${parkingModel!.id}");
      print("parkingModelData:: ${parkingModel}");
    });
    return parkingModel;
  }

  static Future<bool?> setOrder(OrderModel orderModel) async {
    bool isAdded = false;
    await fireStore
        .collection(CollectionName.bookedParkingOrder)
        .doc(orderModel.id)
        .set(orderModel.toJson())
        .then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<List<FaqModel>> getFaq() async {
    List<FaqModel> faqModel = [];
    await fireStore
        .collection(CollectionName.faq)
        .where('enable', isEqualTo: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        FaqModel documentModel = FaqModel.fromJson(element.data());
        faqModel.add(documentModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return faqModel;
  }

  static Future<ReviewModel?> getReview(String orderId) async {
    ReviewModel? reviewModel;
    await fireStore
        .collection(CollectionName.review)
        .doc(orderId)
        .get()
        .then((value) {
      if (value.data() != null) {
        reviewModel = ReviewModel.fromJson(value.data()!);
      }
    });
    return reviewModel;
  }
}
