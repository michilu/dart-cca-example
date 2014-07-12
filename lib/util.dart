library util;

// Temporary, please follow https://github.com/angular/angular.dart/issues/476
@MirrorsUsed(
  targets: const ["util"],
  override: "*")
import "dart:mirrors";

bool isDartium() {
  if (window.navigator.userAgent.match(/\(Dart\)/)) {
    return true;
  } else {
    return false;
  }
}

bool isChromeApps() {
  if (chrome.runtime) {
    return true;
  } else {
    return false;
  }
}

bool isCordova() {
  if (cordova) {
    return true;
  } else {
    return false;
  }
}

bool isIOS() {
  if (cordova && cordova.platformId.match(/^ioss$/)) {
    return true;
  } else {
    return false;
  }
}

String runtime() {
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
