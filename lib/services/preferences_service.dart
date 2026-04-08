// lib/services/preferences_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _recentEmailsKey = 'recent_emails';
  static const String _rememberMeKey = 'remember_me';
  static const String _savedEmailKey = 'saved_email';

  // Sauvegarder les emails récents
  static Future<void> saveRecentEmails(List<String> emails) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentEmailsKey, emails);
  }

  // Récupérer les emails récents
  static Future<List<String>> getRecentEmails() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_recentEmailsKey) ?? [];
  }

  // Ajouter un email récent
  static Future<void> addRecentEmail(String email) async {
    final emails = await getRecentEmails();
    if (!emails.contains(email)) {
      emails.insert(0, email);
      if (emails.length > 5) emails.removeLast();
      await saveRecentEmails(emails);
    }
  }

  // Sauvegarder l'état "Se souvenir de moi"
  static Future<void> setRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, value);
  }

  // Récupérer l'état "Se souvenir de moi"
  static Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberMeKey) ?? false;
  }

  // Sauvegarder l'email mémorisé
  static Future<void> saveSavedEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_savedEmailKey, email);
  }

  // Récupérer l'email mémorisé
  static Future<String?> getSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_savedEmailKey);
  }

  // Effacer toutes les préférences
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}