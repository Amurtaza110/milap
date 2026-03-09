import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

class LiveStreamService {
  static final LiveStreamService _instance = LiveStreamService._internal();
  factory LiveStreamService() => _instance;
  LiveStreamService._internal();

  RtcEngine? _engine;
  
  // TODO: Replace with your actual Agora App ID from console.agora.io
  final String _appId = "YOUR_AGORA_APP_ID";

  Future<void> initialize() async {
    // 1. Request Permissions
    await [Permission.microphone, Permission.camera].request();

    // 2. Initialize Engine
    _engine = createAgoraRtcEngine();
    await _engine!.initialize(RtcEngineContext(appId: _appId));

    // 3. Setup Video
    await _engine!.enableVideo();
    await _engine!.setChannelProfile(ChannelProfileType.channelProfileLiveBroadcasting);
  }

  Future<void> joinChannel(String channelId, bool isHost) async {
    if (_engine == null) await initialize();

    // Set Role
    if (isHost) {
      await _engine!.setClientRole(ClientRoleType.clientRoleBroadcaster);
    } else {
      await _engine!.setClientRole(ClientRoleType.clientRoleAudience);
    }

    // Join (using 0 as uid for auto-assignment)
    await _engine!.joinChannel(
      token: "", // In production, use a token from your dashboard
      channelId: channelId,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  Future<void> leaveChannel() async {
    if (_engine != null) {
      await _engine!.leaveChannel();
      await _engine!.release();
      _engine = null;
    }
  }

  RtcEngine? get engine => _engine;
}
