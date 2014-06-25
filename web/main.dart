library dart_cca;

// Temporary, please follow https://github.com/angular/angular.dart/issues/476
@MirrorsUsed(
  targets: const ["dart_cca"],
  override: "*")
import "dart:mirrors";

import "package:angular/angular.dart";
import "package:angular/application_factory.dart";
import "package:di/di.dart";
import "package:logging/logging.dart";
import "package:dart_cca_example/dart_cca_example.dart";

class MyAppModule extends Module {
  MyAppModule() {
    install(new GoogleCloudEndpointModule());
    value(GoogleCloudEndpointServiceConfig, new GoogleCloudEndpointServiceConfig()
      ..client_id = "client_id.apps.googleusercontent.com"
      ..root_url = "https://a00-00.appspot.com/");
    value(FeedbackFormConfig, new FeedbackFormConfig()
      ..formkey = "formkey");

    install(new DartCCAModule());
  }
}

void main() {
  Logger.root.level = Level.FINEST;
  Logger.root.onRecord.listen((LogRecord r) { print(r.message); });
  applicationFactory()
    .addModule(new MyAppModule())
    .run();
}
