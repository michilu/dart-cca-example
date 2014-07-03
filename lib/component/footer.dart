part of cca_base;

@Component(
  selector: "footer-component",
  templateUrl: "packages/cca_base/component/footer.html",
  applyAuthorStyles: true,
  publishAs: "c"
)
class FooterComponent {

  String get version => _version_service.version;
  VersionService _version_service;
  final year = new DateFormat("y").format(new DateTime.now());

  FooterComponent(this._version_service);

}

class FooterModule extends Module {
  FooterModule() {
    type(FooterComponent);
  }
}
