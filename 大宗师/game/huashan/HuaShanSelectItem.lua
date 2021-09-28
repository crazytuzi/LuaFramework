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
-- 日期：14-10-16
--

local HuaShanSelectItem = class("HuaShanSelectItem", function()
    return CCTableViewCell:new()
end)

function HuaShanSelectItem:getContentSize()
    return CCSizeMake(114, 140)
end

function HuaShanSelectItem:ctor()

end

function HuaShanSelectItem:create(param)
    local _itemData = param.itemData
    local _viewSize = param.viewSize

    dump(_itemData)
    self._icon = require("game.Icon.IconObj").new({
        id = _itemData.cardId,
    })

    self._icon:setPosition(self:getContentSize().width / 2, _viewSize.height / 2 + 5)
    self:addChild(self._icon)

    self:refresh(param)
    return self
end

function HuaShanSelectItem:refresh(param)
    local _itemData = param.itemData
    self._icon:refresh({
        id = _itemData.cardId,
        hp = {_itemData.life, _itemData.initLife},
        level = _itemData.level,
        cls = _itemData.cls
    })
end

return HuaShanSelectItem
