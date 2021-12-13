import 'package:get/get.dart';
import '../../core.dart';

class MeetingController extends GetxController {
  Rxn<List<ListMeeting>> meeting = Rxn<List<ListMeeting>>();
  List<ListMeeting> get meetings => meeting.value;

  Rxn<List<ListMeeting>> meetingBaru = Rxn<List<ListMeeting>>();
  List<ListMeeting> get meetingsBarus => meetingBaru.value;

  Rxn<List<ListMeeting>> meetingEnd = Rxn<List<ListMeeting>>();
  List<ListMeeting> get meetingEnds => meetingEnd.value;

  @override
  void onInit() {
    AuthControllerss().readPreference('uid').then((uid) {
      meeting.bindStream(MeetingService().getMeetingList(uid));
    });

    AuthControllerss().readPreference('uid').then((uid) {
      meetingBaru.bindStream(MeetingService().getMeetingBaruList(uid));
    });

    AuthControllerss().readPreference('uid').then((uid) {
      meetingEnd.bindStream(MeetingService().getMeetingHistoriList(uid));
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
