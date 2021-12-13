import 'package:get/get.dart';

import '../../core.dart';

class PostCaptionBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<PostCaptionController>(PostCaptionController());
  }
}
