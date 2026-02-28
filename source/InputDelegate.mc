import Toybox.Lang;
import Toybox.WatchUi;

class TimerDelegate extends WatchUi.InputDelegate {

    private var _view as TimerView;

    function initialize(view as TimerView) {
        InputDelegate.initialize();
        _view = view;
    }

    function onTap(evt as WatchUi.ClickEvent) as Boolean {
        var coords = evt.getCoordinates();
        _view.handleTap(coords[0], coords[1]);
        return true;
    }

    function onKey(evt as WatchUi.KeyEvent) as Boolean {
        if (evt.getKey() == WatchUi.KEY_ENTER) {
            _view.handleMainKey();
            return true;
        }
        return false;
    }
}
