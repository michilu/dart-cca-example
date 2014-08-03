library localStorage;

import "dart:async";
import "dart:convert";
import "dart:html";

import "package:chrome/chrome_app.dart" as chrome;

import "package:cca_base/platform.dart" as platform;

// Temporary, please follow https://github.com/angular/angular.dart/issues/476
@MirrorsUsed(
  targets: const ["localStorage"],
  override: "*")
import "dart:mirrors";

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
  if (platform.isChromeApps) {
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
  if (platform.isChromeApps) {
    chrome.storage.local.set({normalized_key: normalized_value});
  } else {
    window.localStorage[normalized_key] = normalized_value;
  }
}
