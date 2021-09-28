--LegionTreasurePreviewItem.lua

require("app.cfg.corps_dungeon_award_info")
local EffectNode = require "app.common.effects.EffectNode"

local LegionNewTreasurePreviewItem = class("LegionNewTreasurePreviewItem", function ( ... )
	return CCSItemCellBase:create("ui_layout/legion_DungeonNewTreasureItem.json")
end)

function LegionNewTreasurePreviewItem:ctor( ... )
	self:enableLabelStroke("Label_name", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_count_1", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_count_3", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_count_2", Colors.strokeBrown, 1 )
	self.effectNode = {}
end

function LegionNewTreasurePreviewItem:updateItem(data, startIndex )
	if type(startIndex) ~= "number" then 
		startIndex = 1 
	end
	local firstTreasureIndex = (startIndex - 1)*3 + 1
	local index = 1
	for loopi = firstTreasureIndex, firstTreasureIndex + 2 do 
		local treasureInfo = data[loopi]
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

				if self.effectNode[index] then 
					self.effectNode[index]:removeFromParentAndCleanup(true)
					self.effectNode[index] = nil
				end
				local button = self:getButtonByName("Button_item_"..index)
				if treasureInfo.key == 1 then
					self.effectNode[index] = EffectNode.new("effect_around1")     
					self.effectNode[index]:setScale(1.7) 
					self.effectNode[index]:setPosition(ccp(5,-5))
					self.effectNode[index]:play()
					button:addNode(self.effectNode[index],10)
				end

				self:showTextWithLabel("Label_count_"..index, "x"..treasureInfo.item_size)
				
				local usedCount = treasureInfo.gotCount
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

return LegionNewTreasurePreviewItem


