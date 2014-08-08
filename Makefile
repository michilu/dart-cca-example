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
	node_modules/.bin/yaml2json $< > $@


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
VERSION=lib/version

resource: $(VERSION) $(RESOURCE)


pubserve: $(VERSION) $(ENDPOINTS_LIB) $(RESOURCE)
	-patch -p1 --forward --reverse -i pubbuild.patch
	pub serve --port 8080 --no-dart2js

pubserve-force-poll: $(VERSION) $(ENDPOINTS_LIB) $(RESOURCE)
	-patch -p1 --forward --reverse -i pubbuild.patch
	pub serve --port 8080 --no-dart2js --force-poll

DISCOVERY=assets/echo-v1.discovery
$(ENDPOINTS_LIB):
	cd submodule/discovery_api_dart_client_generator; pub install
	submodule/discovery_api_dart_client_generator/bin/generate.dart --no-prefix -i $(DISCOVERY) -o submodule

VERSION_STRING=$(shell git describe --always --dirty=+)
PROJECT_SINCE=1400976000 #2014/05/25
AUTO_COUNT_SINCE=$(shell echo $$(((`date -u +%s`-$(PROJECT_SINCE))/(24*60*60))))
AUTO_COUNT_LOG=$(shell git log --since=midnight --oneline|wc -l|tr -d " ")
$(VERSION):
	@if [ "$(VERSION_STRING)" != "$(strip $(shell [ -f $@ ] && cat $@))" ] ; then\
		echo 'echo $(VERSION_STRING) > $@' ;\
		echo $(VERSION_STRING) > $@ ;\
		echo $(AUTO_COUNT_SINCE) days since `date -u -r $(PROJECT_SINCE) +%Y-%m-%d`, $(AUTO_COUNT_LOG) commits from midnight. ;\
		node_modules/.bin/yaml2json web/manifest.yaml > web/manifest.json ;\
		sed -i "" -e "s/\$${AUTO_COUNT}/$(AUTO_COUNT_SINCE).$(AUTO_COUNT_LOG)/" web/manifest.json ;\
	fi;


RELEASE_RESOURCE=\
	$(foreach path,$(HTML) $(VERSION),$(subst lib,web/packages/cca_base,$(path)))\
	$(JSON)\
	$(shell find web/icons -name "*.png")\
	web/js/browser_dart_csp_safe.js\
	web/js/main.js\
	web/packages/browser/dart.js\
	web/packages/chrome/bootstrap.js\

RELEASE_CHROME_APPS_RESOURCE=$(RELEASE_RESOURCE) web/main.dart
RELEASE_CORDOVA_RESOURCE=$(RELEASE_RESOURCE)

RELEASE_CHROME_APPS=$(RELEASE_DIR)/chrome-apps
RELEASE_RESOURCE_DIR=
RELEASE_CHROME_APPS_RESOURCE_DIR=$(foreach path,$(RELEASE_RESOURCE_DIR),$(addprefix $(RELEASE_CHROME_APPS)/,$(path)))
BUILD_DIR=build
RELEASE_RESOURCE_SRC_DIR=$(BUILD_DIR)/web
RELEASE_CHROME_APPS_RESOURCE_SRC=$(addprefix $(BUILD_DIR)/,$(RELEASE_CHROME_APPS_RESOURCE))
RELEASE_CHROME_APPS_RESOURCE_DST=$(foreach path,$(RELEASE_CHROME_APPS_RESOURCE_SRC),$(subst $(RELEASE_RESOURCE_SRC_DIR),$(RELEASE_CHROME_APPS),$(path)))
CHROME_APPS_DART_JS=chrome-apps-dart-js
chrome-apps: $(VERSION) $(ENDPOINTS_LIB) $(RESOURCE) $(RELEASE_CHROME_APPS) $(CHROME_APPS_DART_JS) $(RELEASE_CHROME_APPS_RESOURCE_DST)
	make $(RELEASE_CHROME_APPS_RESOURCE_DIR)
	@if [ $(DART_JS) -nt $(RELEASE_CHROME_APPS)/main.dart.precompiled.js ]; then\
		echo "cp $(DART_JS) $(RELEASE_CHROME_APPS)/main.dart.precompiled.js";\
		cp $(DART_JS) $(RELEASE_CHROME_APPS)/main.dart.precompiled.js;\
	fi;
	cd $(RELEASE_DIR) && zip -r -9 -FS chrome-apps.zip chrome-apps

$(RELEASE_CHROME_APPS): $(RELEASE_DIR)
	mkdir -p $@

$(RELEASE_DIR):
	mkdir $@

DART_JS=$(BUILD_DIR)/web/main.dart.precompiled.js
$(CHROME_APPS_DART_JS):
	-patch -p1 --forward --reverse -i pubbuild.patch
	make $(DART_JS)

$(RELEASE_CHROME_APPS_RESOURCE_DST): $(RELEASE_CHROME_APPS_RESOURCE_SRC) $(CHROME_APPS_DART_JS)
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
	rm -f $(foreach path,$(shell find release/chrome-apps -type f -name *.min.css),$(subst .min.css,.css,$(path)))
	rm -f $(foreach path,$(shell find release/chrome-apps -type f -name *.min.js),$(subst .min.js,.js,$(path)))


ios: $(RELEASE_IOS)
	cd $<; cca run ios

ios-sim: $(RELEASE_IOS)
	cd $<; cca emulate ios


RESOURCE_SUFFIX_FOR_BUILD = html css json js
RESOURCE_DIR_FOR_BUILD = web web/js web/view web/packages/cca_base/component web/packages/cca_base/routing web/packages/cca_base/service
RESOURCE_FOR_BUILD = $(foreach suffix,$(RESOURCE_SUFFIX_FOR_BUILD),$(foreach dir,$(RESOURCE_DIR_FOR_BUILD),$(wildcard $(dir)/*.$(suffix))))
BUILD_RESOURCE = $(addprefix build/,$(RESOURCE_FOR_BUILD))
RELEASE_CORDOVA=$(RELEASE_DIR)/cordova
RELEASE_CORDOVA_RESOURCE_DIR=$(foreach path,$(RELEASE_RESOURCE_DIR),$(addprefix $(RELEASE_CORDOVA)/,$(path)))
RELEASE_CORDOVA_RESOURCE_SRC=$(addprefix $(BUILD_DIR)/,$(RELEASE_RESOURCE))
RELEASE_CORDOVA_RESOURCE_DST=$(foreach path,$(RELEASE_CORDOVA_RESOURCE_SRC),$(subst $(RELEASE_RESOURCE_SRC_DIR),$(RELEASE_CORDOVA),$(path)))
CORDOVA_DART_JS=cordova-dart-js
CORDOVA_PLUGINS_TXT=cordova-plugins.txt
CORDOVA_PLUGINS=$(foreach plugin,$(shell cat $(CORDOVA_PLUGINS_TXT)),$(subst submodule/,../../submodule/,$(plugin)))
$(RELEASE_IOS): $(VERSION) $(ENDPOINTS_LIB) $(RESOURCE) $(BUILD_RESOURCE) $(RELEASE_CORDOVA) $(CORDOVA_DART_JS) $(RELEASE_CORDOVA_RESOURCE_DST) $(CORDOVA_PLUGINS_TXT)
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
		cd $@;\
		for plugin in $(CORDOVA_PLUGINS); do\
			echo "cca plugin add $$plugin";\
			cca plugin add $$plugin;\
		done;\
	else\
		cd $@;\
		for plugin in $(CORDOVA_PLUGINS); do\
			echo "cca plugin add $$plugin";\
			cca plugin add $$plugin;\
		done;\
		cca prepare;\
	fi;

build/%: %
	@mkdir -p $(dir $@)
	cp $< $@

$(RELEASE_CORDOVA): $(RELEASE_DIR)
	mkdir -p $@

$(CORDOVA_DART_JS):
	-patch -p1 --forward -i pubbuild.patch
	make $(DART_JS)

$(RELEASE_CORDOVA_RESOURCE_DST): $(RELEASE_CORDOVA_RESOURCE_SRC) $(CORDOVA_DART_JS)
	@if [ ! -d $(dir $@) ]; then\
		mkdir -p $(dir $@);\
	fi;
	cp $(subst $(RELEASE_CORDOVA),$(RELEASE_RESOURCE_SRC_DIR),$@) $@

$(RELEASE_CORDOVA_RESOURCE_DIR): $(foreach path,$(RELEASE_RESOURCE_DIR),$(addprefix $(RELEASE_RESOURCE_SRC_DIR)/,$(path)))
	cp -r $(subst $(RELEASE_CORDOVA),$(RELEASE_RESOURCE_SRC_DIR),$@) $@


PROJECT=DartCCA
xcode: $(RELEASE_IOS)
	open $</platforms/ios/$(PROJECT).xcodeproj


clean:
	rm -f $(VERSION) $(RESOURCE)
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

.PHONY: $(VERSION) $(RELEASE_IOS)
