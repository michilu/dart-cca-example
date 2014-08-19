library main;

// Temporary, please follow https://github.com/angular/angular.dart/issues/476
@MirrorsUsed(
  targets: const ["main"],
  override: "*")
import "dart:mirrors";

import "package:angular/angular.dart" show Module;
import "package:angular/application_factory.dart" show applicationFactory;
import "package:angular_node_bind/angular_node_bind.dart" show NodeBindModule;
import "package:cca_base/cca_base.dart";
import "package:di/di.dart";
import "package:logging/logging.dart";
import "package:polymer/polymer.dart" show initPolymer, Polymer;

class MyAppModule extends Module {
  MyAppModule() {
    install(new GoogleCloudEndpointModule());
    value(GoogleCloudEndpointServiceConfig, new GoogleCloudEndpointServiceConfig()
      ..client_id = "client_id.apps.googleusercontent.com"
      ..root_url = "https://a00-00.appspot.com/");
    value(FeedbackFormConfig, new FeedbackFormConfig()
      ..formkey = "formkey");

    install(new CCABaseModule());
  }
}

void main() {
  Logger.root.level = Level.FINEST;
  Logger.root.onRecord.listen((LogRecord r) { print(r.message); });
  initPolymer().run(() {
    Polymer.onReady.then((_) {
      applicationFactory()
      .addModule(new MyAppModule())
      .addModule(new NodeBindModule())
      .run()
      ;
    });
  });
}
