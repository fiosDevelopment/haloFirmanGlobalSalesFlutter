import 'package:get/get.dart';
import 'package:halo_firman_sales/core.dart';

class CallBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<CallController>(CallController());
  }
}
