library dart_cca_example.google_cloud_endpoints_api_service;

// Temporary, please follow https://github.com/angular/angular.dart/issues/476
@MirrorsUsed(
  targets: const ["dart_cca_example.google_cloud_endpoints_api_service", "echo_v1_api"],
  override: "*")
import "dart:mirrors";

import "dart:async";
import "dart:html";

import "package:angular/angular.dart";
import "package:chrome/chrome_app.dart" as chrome;
import "package:google_oauth2_client/google_oauth2_browser.dart";
import "package:echo_v1_api/echo_v1_api_browser.dart";
import "package:echo_v1_api/echo_v1_api_client.dart";

import "api_service.dart";

class GoogleCloudEndpointModel extends Model {
  Future _loaded;
  GoogleCloudEndpointService _api;
  Map get _model => inner_model;
  Map get _resource => inner_resource;
  set me (dynamic value) {
    _model["me"] = value;
    _resource["me"] = value.toJson();
  }

  GoogleCloudEndpointModel(this._api) {
    inner_model = new Map();
    inner_resource = new Map();
    var load = _get_me();
    if (load != null) {
      _loaded = Future.wait([load]);
    }
  }

  Future _get_me() {
    if (!_api.autoLogin()) {
      return null;
    }
    var completer = _api.loading_completer();
    return _api.me.get().then((response) {
      me = response;
    })
    .catchError((error) {
      if (_api._endpoint.auth.token is String) {
        var details = new chrome.InvalidTokenDetails(token:_api._endpoint.auth.token);
        chrome.identity.removeCachedAuthToken(details)
        .whenComplete(() {
          window.location.hash = "/signup";
        });
      // for dartium
      } else {
        window.location.hash = "/signup";
      }
    }, test: (e) => e is APIRequestError)
    .whenComplete(() {
      completer.complete();
    });
  }

  bool edited(String name) {
    var model = _model[name];
    var resource = _resource[name];
    if (model != null) {
      model = model.toJson();
    }
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

class GoogleCloudEndpointServiceConfig {
  String client_id;
  String root_url;
}

class GoogleCloudEndpointService extends APIService {
  final _REVOKE_URL = "https://accounts.google.com/o/oauth2/revoke?token=";
  final _SCOPES = ["https://www.googleapis.com/auth/userinfo.email"];

  GoogleCloudEndpointServiceConfig c;
  Http _http;
  Echo _endpoint;

  dynamic get comment   => _endpoint.comment ;
  dynamic get issue     => _endpoint.issue   ;
  dynamic get me        => _endpoint.me ;
  dynamic get project   => _endpoint.project ;
  dynamic get user      => _endpoint.user    ;
  dynamic get workload  => _endpoint.workload;

  GoogleCloudEndpointService(this.c, this._http) {
    try {
      // for Google Apps
      var details = new chrome.TokenDetails(interactive:true);
      chrome.identity.getAuthToken(details)
      .then((token) {
        OAuth2 auth = new SimpleOAuth2(token);
        _postLogin(auth);
      });
    // for dartium
    } on UnsupportedError catch(_) {
      GoogleOAuth2 auth = new GoogleOAuth2(c.client_id, _SCOPES, autoLogin:autoLogin());
      _postLogin(auth);
    }
  }

  void _postLogin(auth) {
    _endpoint = new Echo(auth);
    _endpoint.rootUrl = c.root_url;
    _endpoint.makeAuthRequests = true;
    model = new GoogleCloudEndpointModel(this);
  }

  bool autoLogin() {
    bool result;
    switch (window.location.hash) {
      case "#/logout":
      case "#/leave":
        result = false;
        break;
      default:
        result = true;
        break;
    };
    return result;
  }

  MainApiV1MessageUserRequest new_user(data) => new MainApiV1MessageUserRequest.fromJson(data);

  bool logged_in() {
    if (_endpoint == null) {
      return false;
    } else {
      return _endpoint.auth.token != null;
    }
  }

  void logout({String redirect_to: "/"}) {
    var token = _endpoint.auth.token;
    // for dartium
    if (token is! String) {
      token = token.data;
    }
    String revoke_url = _REVOKE_URL + token;
    var completer = loading_completer();
    _http.get(revoke_url)
    .whenComplete(() {
      completer.complete();
      if (_endpoint.auth.token is String) {
        var details = new chrome.InvalidTokenDetails(token:_endpoint.auth.token);
        chrome.identity.removeCachedAuthToken(details)
        .whenComplete(() {
          redirect(redirect_to);
        });
      // for dartium
      } else {
        _endpoint.auth.logout();
        redirect(redirect_to);
      }
    });
  }
}

class GoogleCloudEndpointModule extends Module {
  GoogleCloudEndpointModule() {
    type(GoogleCloudEndpointService);
    factory(APIService, (Injector inj){
      return inj.get(GoogleCloudEndpointService);
    });
  }
}
