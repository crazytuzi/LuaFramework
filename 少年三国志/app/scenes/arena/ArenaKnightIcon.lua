local ArenaKnightIcon = class("ArenaKnightIcon",function ()
	return CCSGUIReaderEx:shareReaderEx():widgetFromJsonFile("ui_layout/treasure_TreasureComposeTreasureItem.json")
end)
require("app.cfg.knight_info")

function ArenaKnightIcon:ctor(_id,...)
    self._name = "buttonName" .. _id
    local knight = knight_info.get(_id)
    local _knightImage = UIHelper:seekWidgetByName(self,"ImageView_treasureItem")
    _knightImage = tolua.cast(_knightImage,"ImageView")
    _knightImage:loadTexture(G_Path.getKnightIcon(knight.res_id),UI_TEX_TYPE_LOCAL)
    local itemButton = UIHelper:seekWidgetByName(self,"Button_treasureItem")
    itemButton = tolua.cast(itemButton,"Button")
    itemButton:setTouchEnabled(true)
    itemButton:setName(self._name)
    __Log("武将名:%s,武将id:%s,武将res_id:%s",knight.name,knight.id,knight.res_id)
    itemButton:loadTextureNormal(G_Path.getEquipColorImage(knight.quality,G_Goods.TYPE_KNIGHT))
    itemButton:loadTexturePressed(G_Path.getEquipColorImage(knight.quality,G_Goods.TYPE_KNIGHT))
end

function ArenaKnightIcon:getButtonName()
    return self._name
end 

--是否显示背景图片
function ArenaKnightIcon:showBackgroundImage(isShow)
    local bgImage = UIHelper:seekWidgetByName(self,"ImageView_bg")
    bgImage:setVisible(isShow)
end

function ArenaKnightIcon:getWidth()
	local width = self:getContentSize().width
	return width
end

return ArenaKnightIcon
