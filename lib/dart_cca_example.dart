library dart_cca_example;

// Temporary, please follow https://github.com/angular/angular.dart/issues/476
@MirrorsUsed(
  targets: const ["dart_cca_example"],
  override: "*")
import "dart:mirrors";

import "dart:async";
import "dart:convert";
import "dart:html";
import "dart:js";

import "package:angular/angular.dart";
import "package:angular/routing/module.dart";
import "package:chrome/chrome_app.dart" as chrome;
import "package:dart_cca_example/service/api_service.dart";
import "package:dart_cca_example/service/google_cloud_endpoints_api_service.dart";
import 'package:intl/intl.dart';

export "package:dart_cca_example/service/google_cloud_endpoints_api_service.dart" show GoogleCloudEndpointModule, GoogleCloudEndpointServiceConfig;

part "component/edit_user.dart";
part "component/feedback.dart";
part "component/footer.dart";
part "routing/router.dart";
part "service/version.dart";

@Controller(
    selector: "[app]",
    publishAs: "a")
class DartCCAController {

  APIService _api;
  dynamic get model => _api.model;

  DartCCAController(this._api);

  bool loading() {
    return _api.loading();
  }

  bool logged_in() {
    return _api.logged_in();
  }

  Completer login() {
    var completer = _api.loading_completer();
    _api.login().whenComplete(() {
      completer.complete();
      switch (window.location.hash) {
        case "#/logout":
        case "#/leave":
          window.location.hash = "";
          break;
      };
    });
    return completer;
  }

  void logout({String redirect_to: "/logout"}) {
    _api.logout(redirect_to: redirect_to);
  }

}

class DartCCAModule extends Module {
  DartCCAModule() {

    install(new EditUserModule());
    install(new FeedbackModule());
    install(new FooterModule());
    install(new VersionServiceModule());

    type(DartCCAController);
    value(RouteInitializerFn, routeInitializer);
    factory(NgRoutingUsePushState,
        (_) => new NgRoutingUsePushState.value(false));
  }
}
