import 'package:angular/angular.dart' show Module;
import 'package:angular/application_factory.dart' show applicationFactory;
import 'package:angular_node_bind/angular_node_bind.dart' show NodeBindModule;
import 'package:polymer/polymer.dart' show initPolymer, Polymer;

// HACK until we fix code gen size. This doesn't really fix it,
// just makes it better.
@MirrorsUsed(override: '*')
import 'dart:mirrors';

class AppModule extends Module {
  void addModule(Module m) => super.install(m);
}

void main() {
  initPolymer().run(() {
    Polymer.onReady.then((_) {
      applicationFactory()
      .addModule(new AppModule())
      .addModule(new NodeBindModule())
      .run()
      ;
    });
  });
}
