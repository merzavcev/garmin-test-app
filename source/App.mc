using Toybox.Application;
using Toybox.WatchUi;

class HelloGarminApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {
    }

    function onStop(state as Dictionary?) as Void {
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [ new HelloGarminView() ];
    }
}

function getApp() as HelloGarminApp {
    return Application.getApp() as HelloGarminApp;
}
