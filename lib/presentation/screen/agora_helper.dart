import 'package:agora_token_generator/agora_token_generator.dart';

class AgoraHelper {
  // Provided credentials loaded via compile-time environment variables or fallbacks
  static const String appId = String.fromEnvironment(
    'AGORA_APP_ID',
    defaultValue: "908f1d1839de4b5ea84a6d88d5b8fa54",
  );

  static const String appCertificate = String.fromEnvironment(
    'AGORA_APP_CERTIFICATE',
    defaultValue: "7002b605563144fab4d45280ca3d1ce9",
  );

  /// Generates a valid Agora RTC Token dynamically for any call session
  static String getToken(String channelName) {
    if (channelName.trim().isEmpty) {
      throw ArgumentError("Channel name cannot be empty when generating an Agora token.");
    }

    const int privilegeExpireTimeInSeconds = 86400; // 24 hours

    return RtcTokenBuilder.buildTokenWithUid(
      appId: appId,
      appCertificate: appCertificate,
      channelName: channelName.trim(),
      uid: 0, // Wildcard UID allows both caregiver and patient to join seamlessly
      tokenExpireSeconds: privilegeExpireTimeInSeconds,
    );
  }
}