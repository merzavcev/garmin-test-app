import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Communications;
import Toybox.PersistedContent;
import Toybox.System;
import Toybox.Time;
import Toybox.WatchUi;

// Request screen states
enum {
    STATE_IDLE    = 0,
    STATE_SENDING = 1,
    STATE_SUCCESS = 2,
    STATE_ERROR   = 3
}

class TimerView extends WatchUi.View {

    private var _state   as Number = STATE_IDLE;
    private var _statusTitle as String = "Ready";
    private var _statusDetail as String = "";
    private var _selectedIndex as Number = 0;
    private var _activePresetId as String or Null = null;
    private var _presets as Array;

    private var _screenW as Number = 360;
    private var _screenH as Number = 360;

    // Button areas [x, y, w, h]
    private var _btnAreas as Array = [];

    function initialize() {
        View.initialize();
        _presets = _defaultPresets();
    }

    function onLayout(dc as Dc) as Void {
        _screenW = dc.getWidth();
        _screenH = dc.getHeight();
        _buildLayout();
    }

    private function _buildLayout() as Void {
        var btnH  = 46;
        var btnW  = 250;
        var btnX  = (_screenW - btnW) / 2;
        var gap   = 8;
        var startY;

        if (_presets.size() == 1) {
            // Place a single action button in the visual center of the screen.
            startY = (_screenH - btnH) / 2;
        } else {
            var bot   = 22;
            var totalHeight = btnH * _presets.size() + gap * (_presets.size() - 1);
            startY = _screenH - totalHeight - bot;
        }

        _btnAreas = [];
        for (var i = 0; i < _presets.size(); i += 1) {
            _btnAreas.add([btnX, startY + i * (btnH + gap), btnW, btnH]);
        }
    }

    function onShow() as Void {
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(_statusColor(), Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            _screenW / 2,
            64,
            Graphics.FONT_MEDIUM,
            _statusTitle,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            _screenW / 2,
            104,
            Graphics.FONT_XTINY,
            _statusDetail,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        for (var i = 0; i < _presets.size(); i += 1) {
            var preset = _presets[i];
            var isSelected = (i == _selectedIndex);
            var color = _colorForButton(i, isSelected);
            _drawBtn(dc, _btnAreas[i], color, preset[:label]);
        }
    }

    private function _drawBtn(dc as Dc, area as Array, color as Number, label as String) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(area[0], area[1], area[2], area[3], 10);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            area[0] + area[2] / 2,
            area[1] + area[3] / 2,
            Graphics.FONT_XTINY,
            label,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    private function _colorForButton(index as Number, isSelected as Boolean) as Number {
        var base = 0x2A5DCC;
        if (index == 1) {
            base = 0x2B8A3E;
        } else if (index == 2) {
            base = 0x8A5B00;
        }

        if (_state == STATE_SENDING) {
            if (_activePresetId != null && _presets[index][:id] == _activePresetId) {
                return 0x666666;
            }
            return 0x2C2C2C;
        }

        if (isSelected) {
            return base;
        }
        return 0x1F1F1F;
    }

    private function _statusColor() as Number {
        if (_state == STATE_SUCCESS) {
            return 0x3CD070;
        }
        if (_state == STATE_ERROR) {
            return 0xFF5F5F;
        }
        if (_state == STATE_SENDING) {
            return 0xFFD166;
        }
        return Graphics.COLOR_WHITE;
    }

    private function _defaultPresets() as Array {
        return [
            {
                :id      => "yandex_lavka",
                :label   => "Яндекс Лавка",
                :method  => Communications.HTTP_REQUEST_METHOD_POST,
                :url     => SecretsConfig.getUrl(),
                :headers => _baseHeaders(),
                :body    => _baseBody()
            }
        ];
    }

    private function _baseHeaders() as Dictionary {
        return SecretsConfig.getHeaders();
    }

    private function _baseBody() as Dictionary {
        return SecretsConfig.getBody();
    }

    function moveSelection(delta as Number) as Void {
        if (_state == STATE_SENDING) {
            return;
        }

        var next = _selectedIndex + delta;
        if (next < 0) {
            next = _presets.size() - 1;
        } else if (next >= _presets.size()) {
            next = 0;
        }

        _selectedIndex = next;
        _statusTitle = "Ready";
        _statusDetail = "";
        WatchUi.requestUpdate();
    }

    function activateSelected() as Void {
        if (_state == STATE_SENDING) {
            return;
        }
        _startRequest(_selectedIndex);
    }

    function handleTap(x as Number, y as Number) as Void {
        if (_state == STATE_SENDING) {
            return;
        }

        for (var i = 0; i < _btnAreas.size(); i += 1) {
            if (_hit(_btnAreas[i], x, y)) {
                _selectedIndex = i;
                _startRequest(i);
                return;
            }
        }
    }

    function _startRequest(index as Number) as Void {
        var preset = _presets[index];

        _activePresetId = preset[:id];
        _state = STATE_SENDING;
        _statusTitle = "Sending...";
        _statusDetail = preset[:label];
        WatchUi.requestUpdate();

        var options = {
            :method => preset[:method],
            :headers => preset[:headers],
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
            :context => preset
        };

        System.println("[PASS] send id=" + preset[:id] + " url=" + preset[:url]);
        try {
            Communications.makeWebRequest(
                preset[:url],
                _buildRequestBody(preset),
                options,
                method(:onWebResponse)
            );
        } catch (ex) {
            _state = STATE_ERROR;
            _activePresetId = null;
            _statusTitle = "Error";
            _statusDetail = "Request failed";
            System.println("[PASS] makeWebRequest exception: " + ex.toString());
            WatchUi.requestUpdate();
        }
    }

    function onWebResponse(
        responseCode as Number,
        data as Dictionary or String or PersistedContent.Iterator or Null,
        context as Object
    ) as Void {
        var presetLabel = "Request";
        if (context != null && context has :label) {
            presetLabel = context[:label];
        }

        System.println("[PASS] response code=" + responseCode.format("%d"));

        if (responseCode >= 200 && responseCode < 300 && _isApiSuccess(data)) {
            _state = STATE_SUCCESS;
            _statusTitle = "Success";
            _statusDetail = presetLabel + " sent";
        } else {
            _state = STATE_ERROR;
            _statusTitle = "Error";
            _statusDetail = _normalizeError(responseCode, data);
        }

        _activePresetId = null;
        WatchUi.requestUpdate();
    }

    private function _isApiSuccess(data) as Boolean {
        if (data == null) {
            return true;
        }
        if (data instanceof Dictionary) {
            if (data has :ok && !data[:ok]) {
                return false;
            }
        }
        return true;
    }

    private function _buildRequestBody(preset as Dictionary) as Dictionary {
        var body = {
            "arriveDate" => Time.now().value(),
            "passes" => preset[:body]["passes"],
            "type" => preset[:body]["type"],
            "subType" => preset[:body]["subType"]
        };
        return body;
    }

    private function _normalizeError(responseCode as Number, data) as String {
        if (responseCode == 401 || responseCode == 403) {
            return "Auth expired";
        }
        if (responseCode >= 500) {
            return "Server error";
        }
        if (responseCode <= 0) {
            return "No connection";
        }

        if (data instanceof Dictionary) {
            if (data has :error) {
                return data[:error].toString();
            }
        }

        return "HTTP " + responseCode.format("%d");
    }

    private function _hit(area as Array, x as Number, y as Number) as Boolean {
        return (x >= area[0] && x <= area[0] + area[2] &&
                y >= area[1] && y <= area[1] + area[3]);
    }
}
