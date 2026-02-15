import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  RemoteConfigService._internal();

  static final RemoteConfigService _instance = RemoteConfigService._internal();

  factory RemoteConfigService() => _instance;

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> initialize() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );

    await _remoteConfig.setDefaults({
      'home_banner_enabled': true,
      'home_banner_text': 'Bienvenidos a Manos del Pueblo',
    });

    await _remoteConfig.fetchAndActivate();
  }

  bool getBool(String key) => _remoteConfig.getBool(key);

  String getString(String key) => _remoteConfig.getString(key);
}
