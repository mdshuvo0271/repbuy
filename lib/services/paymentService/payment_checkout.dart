import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:get/get.dart';
import 'package:shapmanpaypoint/assets/envied/env.dart';
import 'package:shapmanpaypoint/controller/AirtimeTopUp/airtimeController.dart';
import 'package:shapmanpaypoint/controller/Auth/signup_controller.dart';
import 'package:shapmanpaypoint/controller/Effects/on_tap.dart';
import 'package:shapmanpaypoint/controller/Loader/loader_controller.dart';
import 'package:shapmanpaypoint/controller/Payment/payment_controller.dart';
import 'package:shapmanpaypoint/controller/UserInfo/user_info.dart';
import 'package:shapmanpaypoint/controller/master_controller/master_controller.dart';
import 'package:shapmanpaypoint/services/Airtime/airtime_topup_service.dart';
import 'package:shapmanpaypoint/services/paymentService/payment_service.dart';
import 'package:shapmanpaypoint/services/paymentService/payment_verify.dart';
import 'package:shapmanpaypoint/utils/flutter_storage/flutter_storage.dart';
import 'package:shapmanpaypoint/controller/DataBundle/data_bundle.dart';

class PaymentCheckout {
  final PaymentService accesscode = PaymentService();
  final MasterController masterController = Get.find<MasterController>();
  final AirtimeCController airtimeCController = Get.find<AirtimeCController>();
  final UserInfoController userInfo = Get.find<UserInfoController>();
  final PaymentController paymentController = Get.put(PaymentController());
  final loaderController = Get.put(LoaderController());
  final airtimeService = AirtimeTopupService();
  final ontapEffectController = Get.find<OnTapEffect>();
  final stora = SecureStorage();
  final String publicKey = Env.publickey;
  final verifyPayment = PaymentVerify();
  final _databundleController = Get.put(DataBundleController());
  // final DataBundleController _databundleController = Get.find<DataBundleController>();
  Future<void> chargeCardPayment(BuildContext context, title) async {
    final SignUpController editcontroller =
        masterController.signupIsActive.value == true
            ? Get.find<SignUpController>()
            : Get.put(SignUpController());
    try {
      // Ensure Paystack SDK is initialized
      final plugin = PaystackPlugin();
      await plugin.initialize(publicKey: publicKey);
      final accessCode = await accesscode.paymentInit();
      final userData = await stora.readSecureData("ResBody");

      Map<String, dynamic> decodedData = json.decode(userData);
      final userid = decodedData['id'];
      // print(title);
      final dataString = _databundleController.priceController.text ;
      final dataAmount = dataString.isNotEmpty ? double.parse(dataString) : 0.00;
      Charge charge = Charge()
        ..email = editcontroller.email.text.isEmpty
            ? userInfo.email.value
            : editcontroller.email.text
        ..amount = title != "Data Top Up"
            ? int.parse(airtimeCController.amount.value) * 100
            : dataAmount.toInt()
        ..accessCode = accessCode;

      // ignore: use_build_context_synchronously
      CheckoutResponse response = await plugin.checkout(context,
          charge: charge, method: CheckoutMethod.card, fullscreen: true);

      if (response.status == true) {
        ontapEffectController.isBSopen.value = true;
        loaderController.isChecker.value = true;
        final String? reference = response.reference;
        verifyPayment.verifier(reference, title, accessCode, userid);
      } else {
        Get.toNamed(title != "Data Top Up" ? 'recharge' : 'data');
      }
    } catch (e) {
      rethrow;
    }
  }
}
