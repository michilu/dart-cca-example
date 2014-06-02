library dart_cca_example.api_service;

// Temporary, please follow https://github.com/angular/angular.dart/issues/476
@MirrorsUsed(
  targets: const ["dart_cca_example.api_service"],
  override: "*")
import "dart:mirrors";

import "dart:async";
import "dart:html";

class Model {
  Map<String, dynamic> inner_model;
  Map<String, dynamic> inner_resource;
  Map get _model => inner_model;
  Map get _resource => inner_resource;
  dynamic get comment   => _model["comment"] ;
  dynamic get issue     => _model["issue"]   ;
  dynamic get me        => _model["me"]      ;
  dynamic get project   => _model["project"] ;
  dynamic get user      => _model["user"]    ;
  dynamic get workload  => _model["workload"];
  set comment   (dynamic data) => _model["comment"]  = data;
  set issue     (dynamic data) => _model["issue"]    = data;
  set me        (dynamic data) => _model["me"]       = data;
  set project   (dynamic data) => _model["project"]  = data;
  set user      (dynamic data) => _model["user"]     = data;
  set workload  (dynamic data) => _model["workload"] = data;

  Model() {
    inner_model = new Map();
    inner_resource = new Map();
  }

  bool edited(String name) {
    var model = _model[name];
    var resource = _resource[name];
    if (model == resource) {
      return false;
    }
    if (model.length != resource.length) {
      return true;
    }
    for (var key in resource.keys) {
      if (model[key] != resource[key]) {
        return true;
      };
    }
    return false;
  }
}

abstract class APIService {

  List<Completer> _loading_completers = new List();
  Model model;
  dynamic get comment;
  dynamic get issue;
  dynamic get me;
  dynamic get project;
  dynamic get user;
  dynamic get workload;
  dynamic new_user(data) => new Map();

  Completer loading_completer() {
    Completer completer = new Completer();
    _loading_completers.add(completer);
    return completer;
  }

  bool loading() {
    bool result = false;
    List completed = new List();
    for(Completer completer in _loading_completers) {
      if (completer.isCompleted) {
        completed.add(completer);
      } else {
        result = true;
      }
    }
    for(Completer completer in completed) {
      _loading_completers.remove(completer);
    }
    return result;
  }

  bool logged_in() {
  }

  Future login() => new Future.value();

  void redirect(redirect_to) {
    window.location.hash = redirect_to;
    window.location.reload();
  }

  void logout({String redirect_to: "/"}) {
    redirect(redirect_to);
  }
}
