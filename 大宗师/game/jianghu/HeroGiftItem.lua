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
-- 日期：14-10-3
--

local data_item_item = require("data.data_item_item")
local HeroGiftItem = class("HeroGiftItem", function()
    return CCTableViewCell:new()
end)

function HeroGiftItem:getContentSize()
    return CCSizeMake(114, 140)
end

function HeroGiftItem:create(param)
    local _viewSize = param.viewSize

    local proxy = CCBProxy:create()
    self._rootnode = {}
    self._bg = CCBuilderReaderLoad("jianghulu/jianghulu_gift_item.ccbi", proxy, self._rootnode)
    self._bg:setPosition(self:getContentSize().width / 2, _viewSize.height / 2)
    self:addChild(self._bg)

    self:refresh(param)
    return self
end
--
function HeroGiftItem:refresh(param)
    local _itemData = param.itemData

    ResMgr.refreshIcon({
        itemBg = self._rootnode["iconSprite"],
        id = _itemData.resId,
        resType = ResMgr.ITEM
    })

    self._rootnode["valueLabel"]:setString(string.format("+%d", data_item_item[_itemData.resId].price))
    self._rootnode["countLabel"]:setString(tostring(_itemData.num))
--    self._rootnode["itemNameLabel"]:setString(data_item_item[_itemData.resId].name)
--    self._rootnode["iconSprite"]:
end


return HeroGiftItem


