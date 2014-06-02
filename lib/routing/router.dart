part of dart_cca_example;

void routeInitializer(Router router, ViewFactory views) =>
    views.configure({
      "signup": ngRoute(
        path: "/signup",
        view: "view/signup.html"),
      "logout": ngRoute(
        path: "/logout",
        view: "view/logout.html"),
      "leave": ngRoute(
        path: "/leave",
        view: "view/leave.html"),
      "settings": ngRoute(
        path: "/settings",
        view: "view/settings.html"),
      "top": ngRoute(
        defaultRoute: true,
        path: "/",
        view: "view/top.html")
    });
