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
-- 日期：14-10-5
--

local HeroShowItem = class("HeroShowItem", function()
    return CCTableViewCell:new()
end)

function HeroShowItem:getContentSize()
    return CCSizeMake(display.width, 187)
end

function HeroShowItem:create(param)
    local _viewSize = param.viewSize
--    local _itemData = param.itemData

    local proxy = CCBProxy:create()
    self._rootnode = {}
    self._bg = CCBuilderReaderLoad("jianghulu/jianghulu_xiake_item.ccbi", proxy, self._rootnode)
    self._bg:setPosition(_viewSize.width / 2, 0)
    self:addChild(self._bg)

    self:refresh(param)

    return self
end

function HeroShowItem:refresh(param)
    local _itemData = param.itemData

    for i = 1, 5 do
        if _itemData[i] then
            self._rootnode[string.format("headIcon_%d", i)]:setVisible(true)
            local _baseInfo = ResMgr.getCardData(_itemData[i].resId)
            self._rootnode[string.format("heroNameLabel_%d", i)]:setString(_baseInfo.name)
            self._rootnode[string.format("loveLabel_%d", i)]:setString(tostring(_itemData[i].level))
            ResMgr.refreshIcon({
                id = _itemData[i].resId,
                resType = ResMgr.HERO,
                itemBg = self._rootnode[string.format("iconSprite_%d", i)]
            })
        else
            self._rootnode[string.format("headIcon_%d", i)]:setVisible(false)
        end
    end
end
return HeroShowItem

