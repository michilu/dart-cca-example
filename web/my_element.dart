import 'package:polymer/polymer.dart'; // I want to use show here,
                                       // bug http://dartbug.com/16555

@CustomTag('my-element')
class MyElement extends PolymerElement {
  @published String message = 'bindings are neat!';

  MyElement.created() : super.created();
}
