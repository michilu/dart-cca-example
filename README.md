dart-cca-example
================

An example of Cordova Chrome Apps written in AngularDart.

Set up
------

First, checkout this repository:

    $ git clone https://github.com/MiCHiLU/dart-cca-example.git
    $ cd dart-cca-example
    $ bundle install

Then, install cca (Cordova Chrome Apps):

    $ nvm install 0.10
    $ nvm use 0.10
    $ nvm alias default 0.10
    $ npm install -g ios-deploy
    $ npm install -g ios-sim
    $ npm install -g cca

Optional, if you use watchlion:

    $ mkvirtualenv dart-cca-example
    (dart-cca-example)$ pip install -r packages.txt

Build and Test
--------------

    $ make

Run development server
----------------------

    $ make pubserve

then access to:

* http://localhost:8080/

Build the Chrome Apps
---------------------

    $ make chrome-apps

Launch the Chrome Apps via iOS Simulator
----------------------------------------

    $ make ios-sim

Launch the Chrome Apps via iOS device
-------------------------------------

    $ make ios

Open project for iOS with Xcode
-------------------------------

    $ make xcode

How to access to your Google Cloud Endpoints API
------------------------------------------------

Get the discovery file of your Google Cloud Endpoints API:

    $ curl -o assets/<your-api>.discovery https://<your-app-id>.appspot.com/_ah/api/discovery/v1/apis/<your-api>/<your-api-version>/rest

Then, Rewrite `DISCOVERY` and `ENDPOINTS_LIB` line in Makefile:

    DISCOVERY=assets/echo-v1.discovery

    ENDPOINTS_LIB=submodule/dart_echo_v1_api_client

to

    DISCOVERY=assets/<your-api>.discovery

    ENDPOINTS_LIB=submodule/dart_<your-api>_api_client

see: https://github.com/dart-lang/discovery_api_dart_client_generator#generate-your-client-library

Dependencies
------------

* Mac OS X
* GNU Make (https://developer.apple.com/downloads/index.action)
* Bundler
* Node.js v0.10+ (dependenced by cordova)
  * npm@1.4.5+
  * ios-deploy@1.0.6
  * cca@0.1.0

Known Bugs
----------
