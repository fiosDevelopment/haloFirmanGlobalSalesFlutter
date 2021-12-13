import 'package:get/get.dart';
import 'package:halo_firman_sales/services/chat_service.dart';

import '../../../core.dart';

class ChatListController extends GetxController {
  Rxn<List<ChatList>> chatList = Rxn<List<ChatList>>();
  List<ChatList> get chatLists => chatList.value;

  @override
  void onInit() {
    AuthControllerss().readPreference('uid').then((uid) {
      chatList.bindStream(ChatService().getChatList(uid));
    });
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
