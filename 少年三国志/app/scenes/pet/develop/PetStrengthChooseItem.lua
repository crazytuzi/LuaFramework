--PetStrengthChooseItem.lua
local BaseChooseItem = require("app.scenes.common.BaseChooseItem")

local PetStrengthChooseItem = class("PetStrengthChooseItem", BaseChooseItem)

function PetStrengthChooseItem:getSupplyExp( item )
    return item.info.item_value
end

function PetStrengthChooseItem:updateRefineLevel( item )
	 self:showWidgetByName("Label_jingjie",false)
	 self:showWidgetByName("Label_level", false )
	 self:showWidgetByName("Label_level_title", false )
end

function PetStrengthChooseItem:getItemInfo( item )
	return item
end

function PetStrengthChooseItem:getItemIcon( item )
	return item.icon
end


return PetStrengthChooseItem
