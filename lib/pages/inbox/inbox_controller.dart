import 'package:get/get.dart';

import '../../core.dart';

class InboxController extends GetxController {
  Rxn<List<ListInbox>> inbox = Rxn<List<ListInbox>>();
  List<ListInbox> get inboxs => inbox.value;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
