import 'package:get/get.dart';

import '../../../core.dart';

class ChatListBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ChatListController>(ChatListController());
  }
}
