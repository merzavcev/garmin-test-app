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
        var key = evt.getKey();
        if (key == WatchUi.KEY_ENTER) {
            _view.activateSelected();
            return true;
        }

        if (key == WatchUi.KEY_UP) {
            _view.moveSelection(-1);
            return true;
        }

        if (key == WatchUi.KEY_DOWN) {
            _view.moveSelection(1);
            return true;
        }
        return false;
    }
}
