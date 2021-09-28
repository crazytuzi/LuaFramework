local TreasureRobItemKnightItem = class("TreasureRobItemKnightItem",function ()
	return CCSGUIReaderEx:shareReaderEx():widgetFromJsonFile("ui_layout/treasure_TreasureRobItemKnightItem.json")
end)
require("app.cfg.knight_info")

function TreasureRobItemKnightItem:ctor(_id,buttonName,dress_id)
    self._name = buttonName
    local knight = knight_info.get(_id)
    if not knight then
        return
    end
    if not dress_id or type(dress_id) ~= "number" then
        dress_id = 0
    end
    local _knightImage = UIHelper:seekWidgetByName(self,"ImageView_item")
    _knightImage = tolua.cast(_knightImage,"ImageView")
    local res_id = knight.res_id

    if dress_id ~= 0 then
        if knight.type == 1 then   --主角
            res_id = G_Me.dressData:getDressedResidWithDress(knight.id,dress_id)
        end
    end
    _knightImage:loadTexture(G_Path.getKnightIcon(res_id),UI_TEX_TYPE_LOCAL)

    local itemButton = UIHelper:seekWidgetByName(self,"Button_item")
    itemButton = tolua.cast(itemButton,"Button")
    itemButton:setTouchEnabled(true)
    itemButton:setName(buttonName)
    itemButton:loadTextureNormal(G_Path.getEquipColorImage(knight.quality,G_Goods.TYPE_KNIGHT))
    itemButton:loadTexturePressed(G_Path.getEquipColorImage(knight.quality,G_Goods.TYPE_KNIGHT))
end

function TreasureRobItemKnightItem:getButtonName()
    return self._name
end 

function TreasureRobItemKnightItem:getWidth()
	local width = self:getContentSize().width
	return width
end

return TreasureRobItemKnightItem
