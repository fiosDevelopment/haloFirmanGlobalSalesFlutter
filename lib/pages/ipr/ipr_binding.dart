import 'package:get/get.dart';

import '../../core.dart';

class IPRBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<IPRController>(IPRController());
  }
}
