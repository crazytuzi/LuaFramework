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

local CostTipMsgBox = class("CostTipMsgBox", function()
    return require("utility.ShadeLayer").new()
end)

function CostTipMsgBox:ctor(param)
    local _costNum = param.cost
    local _tip  = param.tip
    local _listener = param.listener
    local _cancelListener = param.cancelListener


    local proxy = CCBProxy:create()
    self._rootnode = {}

    local node = CCBuilderReaderLoad("public/cost_tip_msg.ccbi", proxy, self._rootnode)
    node:setPosition(display.cx, display.cy)
    self:addChild(node)

    self._rootnode["cost_num"]:setString(tostring(_costNum))
    self._rootnode["tipLabel"]:setString(tostring(_tip))

    local function close()
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
        if _cancelListener then
            _cancelListener()
        end
        self:removeSelf()
    end

    self._rootnode["closeBtn"]:addHandleOfControlEvent(close, CCControlEventTouchUpInside)

    self._rootnode["cancelBtn"]:addHandleOfControlEvent(close, CCControlEventTouchUpInside)

    self._rootnode["confirmBtn"]:addHandleOfControlEvent(function()
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        _listener()
        self:removeSelf()
    end, CCControlEventTouchUpInside)


end

return CostTipMsgBox

