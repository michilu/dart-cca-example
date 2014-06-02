part of dart_cca_example;

class VersionService {

  Future _loaded;
  Http _http;
  String version;
  final _versionUri = "/packages/dart_cca_example/version";

  VersionService(this._http) {
    var load = _get_version();
    if (load != null) {
      _loaded = Future.wait([load]);
    }
  }

  Future _get_version() {
    return _http.get(_versionUri).then((response) {
      version = response.data;
    });
  }

}

class VersionServiceModule extends Module {
  VersionServiceModule() {
    type(VersionService);
  }
}
