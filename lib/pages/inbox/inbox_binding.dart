import 'package:get/get.dart';

import '../../core.dart';

class InboxBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<InboxController>(InboxController());
  }
}
