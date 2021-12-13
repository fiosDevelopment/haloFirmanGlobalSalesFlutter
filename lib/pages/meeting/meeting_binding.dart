import 'package:get/get.dart';

import '../../core.dart';

class MeetingBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<MeetingController>(MeetingController());
  }
}
