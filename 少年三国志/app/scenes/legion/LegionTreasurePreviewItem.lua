--LegionTreasurePreviewItem.lua

require("app.cfg.corps_dungeon_award_info")

local LegionTreasurePreviewItem = class("LegionTreasurePreviewItem", function ( ... )
	return CCSItemCellBase:create("ui_layout/legion_DungeonTreasureItem.json")
end)

function LegionTreasurePreviewItem:ctor( ... )
	self:enableLabelStroke("Label_name", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_count_1", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_count_3", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_count_2", Colors.strokeBrown, 1 )
end

function LegionTreasurePreviewItem:updateItem( startIndex )
	if type(startIndex) ~= "number" then 
		startIndex = 1 
	end
	
	local firstTreasureIndex = (startIndex - 1)*3 + 1
	local index = 1
	for loopi = firstTreasureIndex, firstTreasureIndex + 2 do 
		local treasureInfo = corps_dungeon_award_info.get(loopi)
		self:showWidgetByName("Panel_item_"..index, treasureInfo and true or false)
		if treasureInfo then 
			local goodInfo = G_Goods.convert(treasureInfo.item_type, treasureInfo.item_value, treasureInfo.item_size)
			if goodInfo then 
				local image = self:getImageViewByName("Image_icon_"..index)
				if image then 
					image:loadTexture(goodInfo.icon, UI_TEX_TYPE_LOCAL)
				end

				image = self:getImageViewByName("Image_pingji_"..index)
				if image then 
					image:loadTexture(G_Path.getAddtionKnightColorImage(goodInfo.quality))
				end

				image = self:getImageViewByName("Image_icon_back_"..index)
				if image then 
					image:loadTexture(G_Path.getEquipIconBack(goodInfo.quality))
				end

				self:showTextWithLabel("Label_count_"..index, "x"..treasureInfo.item_size)
				
				local usedCount = G_Me.legionData:getAwardIndexByIndex(loopi) or 0
				self:showTextWithLabel("Label_total_count_"..index,  G_lang:get("LANG_LEGION_DUNGEON_AWARD_FORMAT", 
					{leftCount=treasureInfo.num - usedCount, maxCount=treasureInfo.num}) )

				self:registerWidgetClickEvent("Button_item_"..index, function ( ... )
					require("app.scenes.common.dropinfo.DropInfo").show(treasureInfo.item_type, treasureInfo.item_value) 
				end)
			end		
		end
		index = index + 1
	end
end

return LegionTreasurePreviewItem


