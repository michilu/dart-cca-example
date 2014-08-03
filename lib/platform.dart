library platform;

import "dart:html";
import "dart:js";

import "package:chrome/chrome_app.dart" as chrome;

// Temporary, please follow https://github.com/angular/angular.dart/issues/476
@MirrorsUsed(
  targets: const ["platform"],
  override: "*")
import "dart:mirrors";

bool get isDartium {
  if (new RegExp("(Dart)").hasMatch(window.navigator.userAgent)) {
    return true;
  } else {
    return false;
  }
}

bool get isChromeApps {
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

bool get isCordova {
  if (context["cordova"] == null) {
    return false;
  } else {
    return true;
  }
}

RegExp _iOSRegExp = new RegExp("^ios\$");

bool get isIOS {
  if (context["cordova"] && _iOSRegExp.hasMatch(context["cordova"]["platformId"])) {
    return true;
  } else {
    return false;
  }
}

String get platform {
  if (isDartium) {
    return "dartium";
  }
  if (isChromeApps) {
    return "chrome_apps";
  }
  if (isIOS) {
    return "ios";
  }
  return "unknown";
}
