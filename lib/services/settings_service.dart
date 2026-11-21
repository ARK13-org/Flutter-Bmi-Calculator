import 'api_client.dart';

class SettingsService {
  SettingsService._();
  static final instance = SettingsService._();
  final _api = ApiClient.instance;
  Future<Map<String, dynamic>> get() async =>
      Map<String, dynamic>.from(await _api.get('/settings') as Map);
  Future<Map<String, dynamic>> update(
          {String? unitSystem,
          bool? notificationsEnabled,
          String? theme}) async =>
      Map<String, dynamic>.from(await _api.patch('/settings', body: {
        if (unitSystem != null) 'unit_system': unitSystem,
        if (notificationsEnabled != null)
          'notifications_enabled': notificationsEnabled,
        if (theme != null) 'theme': theme
      }) as Map);
}
