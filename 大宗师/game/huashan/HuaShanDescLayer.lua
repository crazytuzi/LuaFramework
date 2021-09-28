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
-- 日期：14-11-4
--

local HuaShanDescLayer = class("HuaShanDescLayer", function()
    return require("utility.ShadeLayer").new()
end)

function HuaShanDescLayer:ctor()
    local proxy = CCBProxy:create()
    self._rootnode = {}

    local node = CCBuilderReaderLoad("huashan/huashan_desc.ccbi", proxy, self._rootnode)
    node:setPosition(display.cx, display.cy)
    self:addChild(node)

    local function close()
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
        self:removeSelf()
    end

    self._rootnode["closeBtn"]:addHandleOfControlEvent(close, CCControlEventTouchUpInside)

    self._rootnode["okBtn"]:addHandleOfControlEvent(close, CCControlEventTouchUpInside)
end

return HuaShanDescLayer