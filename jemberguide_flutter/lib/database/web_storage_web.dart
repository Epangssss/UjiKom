import 'dart:html' as html;

class WebStorage {
  static void save(String key, String value) {
    html.window.localStorage[key] = value;
  }
  static String? get(String key) {
    return html.window.localStorage[key];
  }
  static void remove(String key) {
    html.window.localStorage.remove(key);
  }
}
