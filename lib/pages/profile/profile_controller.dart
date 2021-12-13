import 'package:get/get.dart';

import '../../core.dart';

class ProfileController extends GetxController {
  Rxn<List<Follower>> follower = Rxn<List<Follower>>();
  List<Follower> get followers => follower.value;

  Rxn<List<Review>> reviewPelanggan = Rxn<List<Review>>();
  List<Review> get reviews => reviewPelanggan.value;

  Rx<UserList> _userModel = UserList().obs;
  UserList get user => _userModel.value;
  set user(UserList value) => this._userModel.value = value;

  Rxn<List<PostList>> post = Rxn<List<PostList>>();
  List<PostList> get posts => post.value;

  @override
  void onInit() {
    AuthControllerss().readPreference('uid').then((uid) {
      post.bindStream(ProfileService().getPostList(uid));
      follower.bindStream(ProfileService().getFollowersList(uid));
    });
    reviewPelanggan.bindStream(ReviewService().getReviewList());
    _userModel.value = UserList();
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
