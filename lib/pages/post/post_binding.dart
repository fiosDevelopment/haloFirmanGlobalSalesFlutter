import 'package:get/get.dart';

import '../../core.dart';

class PostBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<PostController>(PostController());
  }
}
