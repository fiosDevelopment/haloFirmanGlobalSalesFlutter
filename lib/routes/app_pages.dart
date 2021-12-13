import 'package:get/get.dart';
import 'package:halo_firman_sales/pages/meeting/meeting_detail.dart';

import '../core.dart';

part 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.LOGIN;
  static final routes = [
    GetPage(name: Routes.HOME, page: () => MainView(), binding: MainBinding()),
    GetPage(name: Routes.LOGIN, page: () => LoginView()),
    GetPage(name: Routes.POST, page: () => PostView(), binding: PostBinding()),
    GetPage(
        name: Routes.POST_CATION,
        page: () => PostViewCaption(),
        binding: PostCaptionBinding()),
    GetPage(
        name: Routes.INBOX, page: () => InboxView(), binding: InboxBinding()),
    GetPage(
        name: Routes.CHAT_LIST,
        page: () => ChatListView(),
        binding: ChatListBinding()),
    GetPage(
        name: Routes.CHAT_ROOM,
        page: () => ChatRoomView(),
        binding: ChatRoomBinding()),
    GetPage(
        name: Routes.PROFILE,
        page: () => ProfileView(),
        binding: ProfileBinding()),
    GetPage(
        name: Routes.MEETING,
        page: () => MeetingView(),
        binding: MeetingBinding()),
    GetPage(
        name: Routes.MEETING_HISTORI,
        page: () => MeetingHistoriView(),
        binding: MeetingBinding()),
    GetPage(
        name: Routes.MEETING_DETAIL,
        page: () => MeetingDetailScreen(),
        binding: MeetingBinding()),
    GetPage(
        name: Routes.MEETING_UBAH,
        page: () => MeetingUbahTanggalView(),
        binding: MeetingBinding()),
    GetPage(
        name: Routes.MEETING_BUAT_NOTULEN,
        page: () => BuatNotulenView(),
        binding: MeetingBinding()),
    GetPage(
        name: Routes.MEETING_BATAL,
        page: () => MeetingBatalView(),
        binding: MeetingBinding()),
    GetPage(name: Routes.IPR, page: () => IPRView(), binding: IPRBinding()),
    GetPage(
        name: Routes.SCAN_BARCODE_RESULT,
        page: () => ScanBarcodeResult(),
        binding: ScanBarcodeBinding()),
    GetPage(
        name: Routes.SCAN_BARCODE_INPUT,
        page: () => InputBarcodeView(),
        binding: ScanBarcodeBinding()),
    GetPage(name: Routes.FULL_PHOTO, page: () => FullPhoto()),
  ];
}
