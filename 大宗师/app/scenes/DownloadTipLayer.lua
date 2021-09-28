--
--                   _ooOoo_
--                  o8888888o
--                  88" . "88
--                  (| -_- |)
--                  O\  =  /O
--               ____/`---'\____
--             .'  \\|     |//  `.
--            /  \\|||  :  |||//  \
--           /  _||||| -:- |||||-  \
--           |   | \\\  -  /// |   |
--           | \_|  ''\---/''  |   |
--           \  .-\__  `-`  ___/-. /
--         ___`. .'  /--.--\  `. . __
--      ."" '<  `.___\_<|>_/___.'  >'"".
--     | | :  `- \`.;`\ _ /`;.`/ - ` : | |
--     \  \ `-.   \_ __\ /__ _/   .-` /  /
--======`-.____`-.___\_____/___.-`____.-'======
--                   `=---='
--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
--                 Buddha bless
--
-- 日期：14-10-31
--
require("utility.CCBReaderLoad")
local DownloadTipLayer = class("DownloadTipLayer", function()
    return require("utility.ShadeLayer").new()
end)

function DownloadTipLayer:ctor(param)
    local _size = param.size or 0
    local _listener = param.listener
    local _cancelListener = param.cancelListener

    local proxy = CCBProxy:create()
    self._rootnode = {}

    local node = CCBuilderReaderLoad("public/update_tip.ccbi", proxy, self._rootnode)
    node:setPosition(display.cx, display.cy)
    self:addChild(node)

    self._rootnode["zipSizeLabel"]:setString(string.format("%.2fM", _size / 1024 / 1024))

    local function close()
        if _cancelListener then
            _cancelListener()
        end
        os.exit()
        self:removeSelf()
    end

    self._rootnode["cancelBtn"]:addHandleOfControlEvent(close, CCControlEventTouchUpInside)

    self._rootnode["confirmBtn"]:addHandleOfControlEvent(function()
        self._rootnode["confirmBtn"]:setEnabled(false)
        self:setVisible(false)
        self:performWithDelay(function()
            self:removeSelf()
            _listener()
        end, 0.001)

    end, CCControlEventTouchUpInside)
end

return DownloadTipLayer

