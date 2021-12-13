import 'package:get/get.dart';

import '../../../core.dart';

class ChatRoomBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ChatRoomController>(ChatRoomController());
  }
}
