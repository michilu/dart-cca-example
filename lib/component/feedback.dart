part of dart_cca_example;

class FeedbackFormConfig {
  String formkey;
}

@Component(
  selector: "feedback-component",
  templateUrl: "packages/dart_cca_example/component/feedback_link.html",
  applyAuthorStyles: true,
  publishAs: "c"
)
class FeedbackComponent {
  @NgTwoWay("p")
  var p;

  FeedbackFormConfig _config;
  Http _http;
  Scope scope;
  String description;
  String get version => p.version;

  String get action_url {
    return "https://docs.google.com/spreadsheet/formResponse?formkey=${_config.formkey}";
  }

  FeedbackComponent(this._config, this._http, this.scope);

  void submit(event) {
    String data = new Uri.http(""/*authority*/, ""/*unencodedPath*/, {/*queryParameters*/
      "entry.0.single": description,
      "entry.1.single": version,
      "entry.2.single": window.location.href
    }).query;
    _http.post(action_url, data, headers: {
      "content-type": "application/x-www-form-urlencoded; charset=UTF-8"
    }).then((_response) {
      ok(event);
      description = "";
    });
  }
}

class FeedbackModule extends Module {
  FeedbackModule() {
    type(FeedbackComponent);
  }
}
