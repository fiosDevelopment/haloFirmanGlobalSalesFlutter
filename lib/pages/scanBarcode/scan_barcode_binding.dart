import 'package:get/get.dart';

import '../../core.dart';

class ScanBarcodeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ScanBarcodeController>(ScanBarcodeController());
  }
}
