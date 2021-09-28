--TreasureStrengthChooseItem.lua
local BaseChooseItem = require("app.scenes.common.BaseChooseItem")

local TreasureStrengthChooseItem = class("TreasureStrengthChooseItem", BaseChooseItem)

function TreasureStrengthChooseItem:getSupplyExp( item )
    return item:getSupplyExp()
end

function TreasureStrengthChooseItem:updateRefineLevel( item )
	 self:showWidgetByName("Label_jingjie",false)
end

function TreasureStrengthChooseItem:getItemInfo( item )
	return item:getInfo()
end

function TreasureStrengthChooseItem:getItemIcon( item )
	return item:getIcon()
end


return TreasureStrengthChooseItem
