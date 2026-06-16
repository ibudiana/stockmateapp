import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static late SharedPreferences _prefs;

  // Dipanggil sekali saat aplikasi baru dibuka (di main.dart)
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Pengecekan instan (tanpa await) untuk Router
  static bool get isLoggedInSync => _prefs.getString('current_user_id') != null;

  // Mengambil ID user yang sedang login
  static String? get currentUserId => _prefs.getString('current_user_id');

  // Menyimpan sesi saat login/register berhasil
  static Future<void> saveSession(String userId) async {
    await _prefs.setString('current_user_id', userId);
  }

  // Menghapus sesi saat logout
  static Future<void> clearSession() async {
    await _prefs.remove('current_user_id');
  }
}
