library preferences;

import "dart:async";
import "dart:js";

import "package:cca_base/platform.dart" as platform;
import "package:cca_base/localStorage.dart" as localStorage;

// Temporary, please follow https://github.com/angular/angular.dart/issues/476
@MirrorsUsed(
  targets: const ["preferences"],
  override: "*")
import "dart:mirrors";

var _prefs = context["plugins"]["appPreferences"];

String _key(key) {
  if (!platform.isCordova) {
    key = "preferences:${key}";
  }
  return key;
}

Future get(String key, [dynamic default_value]) {
  if (platform.isCordova) {
    Completer completer = new Completer();
    _prefs.callMethod("fetch", [(value) {
      completer.complete(value);
    }, (error) {
      completer.complete(default_value);
      throw error;
    }, key]);
    return completer.future;
  } else {
    return localStorage.get(_key(key), default_value);
  }
}

Future set(String key, dynamic value) {
  if (platform.isCordova) {
    Completer completer = new Completer();
    _prefs.callMethod("store", [(_value) {
      completer.complete();
    }, (error) {
      completer.complete();
      throw error;
    }, key, value]);
    return completer.future;
  } else {
    return localStorage.set(_key(key), value);
  }
}
