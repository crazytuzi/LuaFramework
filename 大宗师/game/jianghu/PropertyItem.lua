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

local data_item_nature = require("data.data_item_nature")
local PropertyItem = class("HeroGiftItem", function()
    return CCTableViewCell:new()
end)

function PropertyItem:getContentSize()
    return CCSizeMake(211, 37)
end

function PropertyItem:create(param)
    local _viewSize = param.viewSize
    local _idx = param.idx

    local proxy = CCBProxy:create()
    self._rootnode = {}
    self._bg = CCBuilderReaderLoad("jianghulu/jianghulu_prop_item.ccbi", proxy, self._rootnode)
    self._bg:setPosition(_viewSize.width / 2, self._bg:getContentSize().height / 2)
    self:addChild(self._bg)
--
--    self._rootnode["needHeartLabel"]:setString(tostring(_idx))
--    self._bg:setDisplayFrame(display.newSpriteFrame(string.format("jianghulu_prop_%d.png", _idx%2)))

    self:refresh(param)

    return self
end

function PropertyItem:refresh(param)
--    dump(param)
    local _idx = param.idx
    local _itemData = param.itemData
    local _heroLv   = param.heroLv
    self._bg:setDisplayFrame(display.newSpriteFrame(string.format("jianghulu_prop_%d.png", _idx%2)))
    self._rootnode["needHeartLabel"]:setString(tostring(_idx))


    local nature = data_item_nature[_itemData.id]
    self._rootnode["nameLabel"]:setString(nature.nature)
    local str
    if nature.type == 1 then
        str = string.format("+%d", _itemData.val)
    else
        str = string.format("+%d%%", _itemData.val / 100)
    end
    self._rootnode["valueLabel"]:setString(str)

    if _idx > _heroLv then
        self._rootnode["valueLabel"]:setColor(ccc3(59, 29, 1))
        self._rootnode["iconSprite"]:setDisplayFrame(display.newSpriteFrame("jianghulu_love_1.png"))
        self._rootnode["needHeartLabel"]:setColor(ccc3(59, 29, 1))
        self._rootnode["nameLabel"]:setColor(ccc3(59, 29, 1))
    else
        self._rootnode["valueLabel"]:setColor(ccc3(147, 45, 40))
        self._rootnode["iconSprite"]:setDisplayFrame(display.newSpriteFrame("jianghulu_love.png"))
        self._rootnode["needHeartLabel"]:setColor(ccc3(147, 45, 40))
        self._rootnode["nameLabel"]:setColor(ccc3(76, 39, 0))
    end
end


return PropertyItem

