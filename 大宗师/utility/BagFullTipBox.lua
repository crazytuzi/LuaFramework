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

local BagFullTipBox = class("BagFullTipBox", function()
    return require("utility.ShadeLayer").new()
end)

function BagFullTipBox:ctor(param)
    local _costNum = param.cost
    local _name    = param.name
    local _size    = param.size
    local _listener= param.listener
    local _cancelListener = param.cancelListener


    local proxy = CCBProxy:create()
    self._rootnode = {}

    local node = CCBuilderReaderLoad("public/bag_full_tip_msg.ccbi", proxy, self._rootnode)
    node:setPosition(display.cx, display.cy)
    self:addChild(node)

    self._rootnode["costLabel"]:setString(tostring(_costNum))
    self._rootnode["bagName"]:setString(tostring(_name))
    self._rootnode["sizeLabel"]:setString(tostring(_size))

    self._rootnode["closeBtn"]:addHandleOfControlEvent(function()
        self:removeSelf()
    end, CCControlEventTouchUpInside)

    self._rootnode["cancelBtn"]:addHandleOfControlEvent(function()
        if _cancelListener then
            _cancelListener()
        end
        self:removeSelf()
    end, CCControlEventTouchUpInside)

    self._rootnode["confirmBtn"]:addHandleOfControlEvent(function()
        _listener()
        self:removeSelf()
    end, CCControlEventTouchUpInside)


end

return BagFullTipBox

