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
-- 日期：14-10-17
--

local HuaShanHeroItem = class("HuaShanHeroItem", function()
    return CCTableViewCell:new()
end)

function HuaShanHeroItem:getContentSize()
    return CCSizeMake(display.width, 187)
end

function HuaShanHeroItem:ctor()

end

function HuaShanHeroItem:create(param)
    local _itemData = param.itemData
    local _viewSize = param.viewSize

    local proxy = CCBProxy:create()
    self._rootnode = {}
    self._bg = CCBuilderReaderLoad("huashan/huashan_choose_item.ccbi", proxy, self._rootnode)
    self._bg:setPosition(_viewSize.width / 2, 0)
    self:addChild(self._bg)

    self._icon = {}
    for i = 1, 5 do
        if _itemData[i] then
            self._icon[i] = require("game.Icon.IconObj").new({
                id = _itemData[i].cardId,
                hp = {_itemData[i].life, _itemData[i].initLife},
                level = _itemData[i].level,
                cls = _itemData[i].cls
            })
        else
            self._icon[i] = require("game.Icon.IconObj").new({
--                id = 0,
            })
        end
        self._icon[i]:setPosition(self._icon[i]:getContentSize().width / 2, self:getContentSize().height / 2 + 5)
        self._rootnode["headIcon_" .. tostring(i)]:addChild(self._icon[i])
    end

--    dump(_itemData)

    self:refresh(param)
    return self
end

function HuaShanHeroItem:refresh(param)
    local _itemData = param.itemData

    for i = 1, 5 do
        if _itemData[i] then
            self._icon[i]:setVisible(true)
            self._icon[i]:refresh({
                id = _itemData[i].cardId,
                state = _itemData[i].state,
                hp = {_itemData[i].life, _itemData[i].initLife},
                level = _itemData[i].level,
                cls = _itemData[i].cls
            })
        else
            self._icon[i]:setVisible(false)
        end
    end

end

return HuaShanHeroItem

