import 'package:flutter/material.dart';

import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:halo_firman_sales/managers/call_manager.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class IncomingCallScreen extends StatelessWidget {
  final P2PSession _callSession;

  IncomingCallScreen(this._callSession);

  @override
  Widget build(BuildContext context) {
    _callSession.onSessionClosed = (callSession) {
      log("_onSessionClosed");
      Navigator.pop(context);
    };

    return WillPopScope(
        onWillPop: () => _onBackPressed(context),
        child: Scaffold(
            backgroundColor: Color(0xff091b3f),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(36),
                    child: Text(_getCallTitle(),
                        style: TextStyle(
                            fontSize: 28,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
                  FutureBuilder<CubeUser>(
                    future: getUserById(_callSession.callerId),
                    builder: (context, sn) {
                      return sn.data == null
                          ? Center(child: CircularProgressIndicator())
                          : Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    sn.data.fullName,
                                    style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  Stack(
                                    children: [
                                      Container(
                                        width: 200,
                                        height: 200,
                                        padding: EdgeInsets.all(20.0),
                                        decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(120)),
                                        child: CircleAvatar(
                                          backgroundImage:
                                              NetworkImage(sn.data.avatar),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                    },
                  ),
                  SizedBox(
                    height: 60,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(right: 36),
                        child: FloatingActionButton(
                          heroTag: "RejectCall",
                          child: Icon(
                            Icons.call_end,
                            color: Colors.white,
                          ),
                          backgroundColor: Colors.red,
                          onPressed: () => _rejectCall(context, _callSession),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 36),
                        child: FloatingActionButton(
                          heroTag: "AcceptCall",
                          child: Icon(
                            Icons.call,
                            color: Colors.white,
                          ),
                          backgroundColor: Colors.green,
                          onPressed: () => _acceptCall(context, _callSession),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )));
  }

  _getCallTitle() {
    String callType;

    switch (_callSession.callType) {
      case CallType.VIDEO_CALL:
        callType = "Panggilan Video Masuk";
        break;
      case CallType.AUDIO_CALL:
        callType = "Panggilan Suara Masuk";
        break;
    }

    return "$callType";
  }

  void _acceptCall(BuildContext context, P2PSession callSession) {
    CallManager.instance.acceptCall(callSession.sessionId);
    FlutterRingtonePlayer.stop();
  }

  void _rejectCall(BuildContext context, P2PSession callSession) {
    CallManager.instance.reject(callSession.sessionId);
    FlutterRingtonePlayer.stop();
  }

  Future<bool> _onBackPressed(BuildContext context) {
    return Future.value(false);
  }
}
