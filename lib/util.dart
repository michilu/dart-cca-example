library util;

import "dart:async";
import "dart:convert";
import "dart:html";

import "package:chrome/chrome_app.dart" as chrome;

// Temporary, please follow https://github.com/angular/angular.dart/issues/476
@MirrorsUsed(
  targets: const ["util"],
  override: "*")
import "dart:mirrors";

bool isDartium() {
  if (new RegExp("(Dart)").hasMatch(window.navigator.userAgent)) {
    return true;
  } else {
    return false;
  }
}

bool isChromeApps() {
  try {
    if (chrome.runtime.id == null) {
      return false;
    } else {
      return true;
    }
  } catch (_) {
    return false;
  }
}

bool isCordova() {
  if (cordova == null) {
    return false;
  } else {
    return true;
  }
}

bool isIOS() {
  if (cordova && new RegExp("^ios\$").hasMatch(cordova.platformId)) {
    return true;
  } else {
    return false;
  }
}

String runtime() {
  if (isDartium()) {
    return "dartium";
  }
  if (isChromeApps()) {
    return "chrome_apps";
  }
  if (isIOS()) {
    return "ios";
  }
  return "unknown";
}

class localStorage {

  String _encode(dynamic value) {
    if (value is! String) {
      value = JSON.encode(value);
    }
    return value;
  }

  String _decode(dynamic value) {
    try {
      return JSON.decode(value);
    } on FormatException catch(_) {
      return value;
    }
  }

  Future get(dynamic key, [dynamic default_value]) {
    String normalized_key = _encode(key);
    if (isChromeApps()) {
      Completer completer = new Completer();
      chrome.storage.local.get([normalized_key]).then((Map<String,String> values) {
        var result;
        var value = values[normalized_key];
        if (value == null) {
          result = default_value;
        } else {
          result = _decode(value);
        }
        completer.complete(result);
      });
      return completer.future;
    } else {
      var result;
      var value = window.localStorage[normalized_key];
      if (value == null) {
        result = default_value;
      } else {
        result = _decode(value);
      }
      return new Future.value(result);
    }
  }

  void set(dynamic key, dynamic value) {
    String normalized_key = _encode(key);
    String normalized_value = JSON.encode(value);
    if (isChromeApps()) {
      chrome.storage.local.set({normalized_key: normalized_value});
    } else {
      window.localStorage[normalized_key] = normalized_value;
    }
  }
}
