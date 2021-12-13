import 'package:get/get.dart';

import '../../core.dart';

class HomeController extends GetxController {
  Rx<UserList> _userModel = UserList().obs;
  UserList get user => _userModel.value;
  set user(UserList value) => this._userModel.value = value;

  Rxn<List<HomeMenu>> menusales = Rxn<List<HomeMenu>>();
  List<HomeMenu> get menusaless => menusales.value;

  @override
  void onInit() {
    _userModel.value = UserList();

    menusales.bindStream(HomeService().getMenuListSales());
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
