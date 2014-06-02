.SUFFIXES: .haml .html
.haml.html:
	haml -f html5 -t ugly $< $@

.SUFFIXES: .sass .css
.sass.css:
	compass compile $< -c $(CSS_DIR)/config.rb

.SUFFIXES: .sass .min.css
.sass.min.css:
	compass compile --environment production $< -c $(CSS_DIR)/config.rb
	mv $*.css $@

.SUFFIXES: .yaml .json
.yaml.json:
	cat $< |python -c "import json,yaml,sys; print(json.dumps(yaml.load(sys.stdin.read()), indent=2))" > $@


RELEASE_DIR=release
RELEASE_IOS=$(RELEASE_DIR)/ios
all: chrome-apps $(RELEASE_IOS)


ENDPOINTS_LIB=submodule/dart_echo_v1_api_client
RESOURCE_DIR_PATH=web lib
RESOURCE_DIR=$(foreach dir,$(shell find $(RESOURCE_DIR_PATH) -type d),$(dir))
HAML=$(foreach dir,$(RESOURCE_DIR),$(wildcard $(dir)/*.haml))
HTML=$(HAML:.haml=.html)
SASS=$(foreach dir,$(RESOURCE_DIR),$(wildcard $(dir)/*.sass))
CSS=$(SASS:.sass=.css)
MINCSS=$(SASS:.sass=.min.css)
YAML=$(shell find web -type f -name "[^.]*.yaml")
JSON=$(YAML:.yaml=.json)
RESOURCE=$(HTML) $(CSS) $(MINCSS) $(JSON)
VERSION_HTML=lib/version

resource: $(RESOURCE) $(VERSION_HTML)


pubserve: $(VERSION_HTML) $(ENDPOINTS_LIB) $(RESOURCE)
	-patch -p1 --forward --reverse -i pubbuild.patch
	pub serve --port 8080 --no-dart2js

pubserve-force-poll: $(VERSION_HTML) $(ENDPOINTS_LIB) $(RESOURCE)
	-patch -p1 --forward --reverse -i pubbuild.patch
	pub serve --port 8080 --no-dart2js --force-poll

DISCOVERY=assets/echo-v1.discovery
$(ENDPOINTS_LIB):
	cd submodule/discovery_api_dart_client_generator; pub install
	submodule/discovery_api_dart_client_generator/bin/generate.dart --no-prefix -i $(DISCOVERY) -o submodule

VERSION=$(shell git describe --always --dirty=+)
$(VERSION_HTML):
	@if [ "$(VERSION)" != "$(strip $(shell [ -f $@ ] && cat $@))" ] ; then\
		echo 'echo $(VERSION) > $@' ;\
		echo $(VERSION) > $@ ;\
	fi;


RELEASE_RESOURCE=\
	$(foreach path,$(HTML) $(VERSION_HTML),$(subst lib,web/packages/dart_cca_example,$(path)))\
	$(JSON)\
	$(shell find web/icons -name "*.png")\
	web/js/browser_dart_csp_safe.js\
	web/js/main.js\
	web/main.dart\
	web/packages/browser/dart.js\
	web/packages/chrome/bootstrap.js\
	web/packages/shadow_dom/shadow_dom.min.js\

RELEASE_CHROME_APPS=$(RELEASE_DIR)/chrome-apps
RELEASE_RESOURCE_DIR=ionic-1.0.0-beta.6
RELEASE_CHROME_APPS_RESOURCE_DIR=$(foreach path,$(RELEASE_RESOURCE_DIR),$(addprefix $(RELEASE_CHROME_APPS)/,$(path)))
BUILD_DIR=build
RELEASE_RESOURCE_SRC_DIR=$(BUILD_DIR)/web
RELEASE_RESOURCE_SRC=$(addprefix $(BUILD_DIR)/,$(RELEASE_RESOURCE))
RELEASE_CHROME_APPS_RESOURCE_DST=$(foreach path,$(RELEASE_RESOURCE_SRC),$(subst $(RELEASE_RESOURCE_SRC_DIR),$(RELEASE_CHROME_APPS),$(path)))
CHROME_APPS_DART_JS=chrome-apps-dart-js
chrome-apps: $(VERSION_HTML) $(ENDPOINTS_LIB) $(RESOURCE) $(RELEASE_CHROME_APPS) $(CHROME_APPS_DART_JS) $(RELEASE_CHROME_APPS_RESOURCE_DST)
	make $(RELEASE_CHROME_APPS_RESOURCE_DIR)
	@if [ $(DART_JS) -nt $(RELEASE_CHROME_APPS)/main.dart.precompiled.js ]; then\
		echo "cp $(DART_JS) $(RELEASE_CHROME_APPS)/main.dart.precompiled.js";\
		cp $(DART_JS) $(RELEASE_CHROME_APPS)/main.dart.precompiled.js;\
	fi;

$(RELEASE_CHROME_APPS): $(RELEASE_DIR)
	mkdir -p $@

$(RELEASE_DIR):
	mkdir $@

DART_JS=$(BUILD_DIR)/web/main.dart.precompiled.js
$(CHROME_APPS_DART_JS):
	-patch -p1 --forward --reverse -i pubbuild.patch
	make $(DART_JS)

$(RELEASE_CHROME_APPS_RESOURCE_DST): $(RELEASE_RESOURCE_SRC) $(CHROME_APPS_DART_JS)
	@if [ ! -d $(dir $@) ]; then\
		mkdir -p $(dir $@);\
	fi;
	cp $(subst $(RELEASE_CHROME_APPS),$(RELEASE_RESOURCE_SRC_DIR),$@) $@

$(RELEASE_DIR)/%: %
	@mkdir -p $(dir $@)
	@if [ -d $< ]; then\
		echo "cp -r $< $@";\
		cp -r $< $@;\
	else\
		if [ $< -nt $@ ]; then\
		  echo "cp $< $@";\
		  cp $< $@;\
		fi;\
	fi;

DART=$(foreach dir,$(RESOURCE_DIR),$(wildcard $(dir)/*.dart))
$(DART_JS): pubspec.yaml $(DART)
	pub build

$(RELEASE_CHROME_APPS_RESOURCE_DIR): $(foreach path,$(RELEASE_RESOURCE_DIR),$(addprefix $(RELEASE_RESOURCE_SRC_DIR)/,$(path)))
	cp -r $(subst $(RELEASE_CHROME_APPS),$(RELEASE_RESOURCE_SRC_DIR),$@) $@


ios: $(RELEASE_IOS)
	cd $<; cca run ios

ios-sim: $(RELEASE_IOS)
	cd $<; cca emulate ios


RESOURCE_SUFFIX_FOR_BUILD = html css json js
RESOURCE_DIR_FOR_BUILD = web web/js web/view web/packages/dart_cca_example/component web/packages/dart_cca_example/routing web/packages/dart_cca_example/service
RESOURCE_FOR_BUILD = $(foreach suffix,$(RESOURCE_SUFFIX_FOR_BUILD),$(foreach dir,$(RESOURCE_DIR_FOR_BUILD),$(wildcard $(dir)/*.$(suffix))))
BUILD_RESOURCE = $(addprefix build/,$(RESOURCE_FOR_BUILD))
RELEASE_CORDOVA=$(RELEASE_DIR)/cordova
RELEASE_CORDOVA_RESOURCE_DIR=$(foreach path,$(RELEASE_RESOURCE_DIR),$(addprefix $(RELEASE_CORDOVA)/,$(path)))
RELEASE_CORDOVA_RESOURCE_DST=$(foreach path,$(RELEASE_RESOURCE_SRC),$(subst $(RELEASE_RESOURCE_SRC_DIR),$(RELEASE_CORDOVA),$(path)))
CORDOVA_DART_JS=cordova-dart-js
$(RELEASE_IOS): $(VERSION_HTML) $(ENDPOINTS_LIB) $(RESOURCE) $(BUILD_RESOURCE) $(RELEASE_CORDOVA) $(CORDOVA_DART_JS) $(RELEASE_CORDOVA_RESOURCE_DST)
	make $(RELEASE_CORDOVA_RESOURCE_DIR)
	@if [ $(DART_JS) -nt $(RELEASE_CORDOVA)/main.dart.precompiled.js ]; then\
		echo "cp $(DART_JS) $(RELEASE_CORDOVA)/main.dart.precompiled.js";\
		cp $(DART_JS) $(RELEASE_CORDOVA)/main.dart.precompiled.js;\
	fi;
	@if ! (cd $@ && cca prepare); then\
		echo "rm -rf $@";\
		rm -rf $@;\
		echo "cca create $@ --link-to=$(RELEASE_CORDOVA)/manifest.json";\
		cca create $@ --link-to=$(RELEASE_CORDOVA)/manifest.json;\
		echo "git checkout release/ios/config.xml";\
		git checkout release/ios/config.xml;\
	fi;

build/%: %
	@mkdir -p $(dir $@)
	cp $< $@

$(RELEASE_CORDOVA): $(RELEASE_DIR)
	mkdir -p $@

$(CORDOVA_DART_JS):
	-patch -p1 --forward -i pubbuild.patch
	make $(DART_JS)

$(RELEASE_CORDOVA_RESOURCE_DST): $(RELEASE_RESOURCE_SRC) $(CORDOVA_DART_JS)
	@if [ ! -d $(dir $@) ]; then\
		mkdir -p $(dir $@);\
	fi;
	cp $(subst $(RELEASE_CORDOVA),$(RELEASE_RESOURCE_SRC_DIR),$@) $@

$(RELEASE_CORDOVA_RESOURCE_DIR): $(foreach path,$(RELEASE_RESOURCE_DIR),$(addprefix $(RELEASE_RESOURCE_SRC_DIR)/,$(path)))
	cp -r $(subst $(RELEASE_CORDOVA),$(RELEASE_RESOURCE_SRC_DIR),$@) $@


xcode: $(RELEASE_IOS)
	open $</platforms/ios/DartCCA.xcodeproj


clean:
	rm -f $(VERSION_HTML) $(RESOURCE)
	rm -rf $(BUILD_DIR) $(RELEASE_DIR)
	git checkout release/ios/config.xml
	-patch -p1 --forward --reverse -i pubbuild.patch

clean-all: clean
	rm -f pubspec.lock pubspec.yaml.orig pubspec.yaml.rej
	rm -rf $(ENDPOINTS_LIB) packages
	find . -name "*.sw?" -delete
	find . -name .DS_Store -delete
	find . -name packages -type l -delete
	find . -type d -name .sass-cache |xargs rm -rf

.PHONY: $(VERSION_HTML) $(RELEASE_IOS)
