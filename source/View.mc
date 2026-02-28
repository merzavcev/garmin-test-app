import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Timer;
import Toybox.WatchUi;

// Timer states
enum {
    STATE_IDLE    = 0,
    STATE_RUNNING = 1,
    STATE_PAUSED  = 2,
    STATE_STOPPED = 3
}

class TimerView extends WatchUi.View {

    private var _state   as Number = STATE_IDLE;
    private var _elapsed as Number = 0;   // accumulated ms at pause/stop
    private var _startMs as Number = 0;   // System.getTimer() at last start/resume
    private var _hwTimer as Timer.Timer;

    private var _screenW as Number = 360;
    private var _screenH as Number = 360;

    // Precomputed button areas [x, y, w, h]
    // Stacked vertically so both fit inside round display
    private var _btnSingle as Array = [0, 0, 0, 0]; // Start / Reset
    private var _btnTop    as Array = [0, 0, 0, 0]; // Pause / Resume  (upper slot)
    private var _btnBot    as Array = [0, 0, 0, 0]; // Stop             (lower slot)

    function initialize() {
        View.initialize();
        _hwTimer = new Timer.Timer();
    }

    function onLayout(dc as Dc) as Void {
        _screenW = dc.getWidth();
        _screenH = dc.getHeight();
        _buildLayout();
    }

    private function _buildLayout() as Void {
        // 180 px wide buttons are safe across the full height of a round 360x360 display.
        // Two buttons stacked with 9 px gap, 22 px bottom margin.
        var btnH  = 46;
        var btnW  = 180;
        var btnX  = (_screenW - btnW) / 2;
        var gap   = 9;
        var bot   = 22;

        var topY  = _screenH - btnH * 2 - gap - bot;   // upper slot
        var botY  = topY + btnH + gap;                  // lower slot
        var midY  = topY + (btnH + gap) / 2;            // single button centred in zone

        _btnSingle = [btnX, midY, btnW, btnH];
        _btnTop    = [btnX, topY, btnW, btnH];
        _btnBot    = [btnX, botY, btnW, btnH];
    }

    function onShow() as Void {
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        var elapsed = _getCurrentElapsed();

        // MM:SS — large
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            _screenW / 2,
            _screenH / 2 - 40,
            Graphics.FONT_NUMBER_HOT,
            _formatMajor(elapsed),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        // .mmm — medium, below MM:SS
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            _screenW / 2,
            _screenH / 2 + 28,
            Graphics.FONT_NUMBER_MEDIUM,
            _formatMinor(elapsed),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        // Status label (PAUSED / STOPPED)
        if (_state == STATE_PAUSED) {
            _drawLabel(dc, "PAUSED");
        } else if (_state == STATE_STOPPED) {
            _drawLabel(dc, "STOPPED");
        }

        // Buttons — stacked vertically
        if (_state == STATE_IDLE) {
            _drawBtn(dc, _btnSingle, 0x00AA00, "Start");
        } else if (_state == STATE_RUNNING) {
            _drawBtn(dc, _btnTop, 0xFF8800, "Pause");
            _drawBtn(dc, _btnBot, 0xCC0000, "Stop");
        } else if (_state == STATE_PAUSED) {
            _drawBtn(dc, _btnTop, 0x00AA00, "Resume");
            _drawBtn(dc, _btnBot, 0xCC0000, "Stop");
        } else if (_state == STATE_STOPPED) {
            _drawBtn(dc, _btnSingle, 0x0066CC, "Reset");
        }
    }

    private function _drawLabel(dc as Dc, text as String) as Void {
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            _screenW / 2,
            _screenH / 2 + 66,
            Graphics.FONT_SMALL,
            text,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    private function _drawBtn(dc as Dc, area as Array, color as Number, label as String) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(area[0], area[1], area[2], area[3], 10);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            area[0] + area[2] / 2,
            area[1] + area[3] / 2,
            Graphics.FONT_SMALL,
            label,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    private function _formatMajor(ms as Number) as String {
        var totalSecs = ms / 1000;
        var mins = totalSecs / 60;
        var secs = totalSecs % 60;
        return mins.format("%02d") + ":" + secs.format("%02d");
    }

    private function _formatMinor(ms as Number) as String {
        return "." + (ms % 1000).format("%03d");
    }

    private function _getCurrentElapsed() as Number {
        if (_state == STATE_RUNNING) {
            return _elapsed + (System.getTimer() - _startMs);
        }
        return _elapsed;
    }

    function onHide() as Void {
        _hwTimer.stop();
    }

    // ---- State transitions ----

    function doStart() as Void {
        _elapsed = 0;
        _startMs = System.getTimer();
        _state   = STATE_RUNNING;
        _hwTimer.start(method(:onTick), 50, true);
        WatchUi.requestUpdate();
    }

    function doPause() as Void {
        _elapsed += System.getTimer() - _startMs;
        _state    = STATE_PAUSED;
        _hwTimer.stop();
        WatchUi.requestUpdate();
    }

    function doResume() as Void {
        _startMs = System.getTimer();
        _state   = STATE_RUNNING;
        _hwTimer.start(method(:onTick), 50, true);
        WatchUi.requestUpdate();
    }

    function doStop() as Void {
        if (_state == STATE_RUNNING) {
            _elapsed += System.getTimer() - _startMs;
        }
        _state = STATE_STOPPED;
        _hwTimer.stop();
        WatchUi.requestUpdate();
    }

    function doReset() as Void {
        _elapsed = 0;
        _state   = STATE_IDLE;
        WatchUi.requestUpdate();
    }

    function onTick() as Void {
        WatchUi.requestUpdate();
    }

    // ---- Input dispatching ----

    function handleTap(x as Number, y as Number) as Void {
        if (_state == STATE_IDLE) {
            if (_hit(_btnSingle, x, y)) { doStart(); }
        } else if (_state == STATE_RUNNING) {
            if (_hit(_btnTop, x, y)) { doPause(); }
            if (_hit(_btnBot, x, y)) { doStop();  }
        } else if (_state == STATE_PAUSED) {
            if (_hit(_btnTop, x, y)) { doResume(); }
            if (_hit(_btnBot, x, y)) { doStop();   }
        } else if (_state == STATE_STOPPED) {
            if (_hit(_btnSingle, x, y)) { doReset(); }
        }
    }

    // Physical START/ENTER button cycles through main actions
    function handleMainKey() as Void {
        if      (_state == STATE_IDLE)    { doStart();  }
        else if (_state == STATE_RUNNING) { doPause();  }
        else if (_state == STATE_PAUSED)  { doResume(); }
        else if (_state == STATE_STOPPED) { doReset();  }
    }

    private function _hit(area as Array, x as Number, y as Number) as Boolean {
        return (x >= area[0] && x <= area[0] + area[2] &&
                y >= area[1] && y <= area[1] + area[3]);
    }
}
