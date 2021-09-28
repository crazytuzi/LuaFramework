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
-- 日期：14-11-5
--
local data_item_item = require("data.data_item_item")

local SpiritGetTip = class("SpiritGetTip", function()
    return display.newNode()
end)

function SpiritGetTip:ctor(info)
    local proxy = CCBProxy:create()
    self._rootnode = {}
    local node = CCBuilderReaderLoad("spirit/spirit_get_tip.ccbi", proxy, self._rootnode)
    node:setPosition(display.cx, display.cy)
    self:addChild(node, 3)

    for i = 1, 10 do
        if info[i] then
            local item = data_item_item[info[i].resId]
            self._rootnode[string.format("nameLabel%d", i)]:setString(tostring(item.name))
            self._rootnode[string.format("nameLabel%d", i)]:setColor(NAME_COLOR[item.quality])
        end
    end

    local action = transition.sequence({
        CCDelayTime:create(2),
        CCFadeOut:create(0.5),
        CCRemoveSelf:create(true)
    })
    self:runAction(action)
end

return SpiritGetTip

