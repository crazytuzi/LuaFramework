--LegionHitEggItem.lua

require("app.cfg.corps_dungeon_award_info")

local LegionHitEggItem = class("LegionHitEggItem", function ( ... )
	return CCSItemCellBase:create("ui_layout/legion_DungeonEggItem.json")
end)

function LegionHitEggItem:ctor( ... )
	self:enableLabelStroke("Label_player_name_1", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_player_name_2", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_player_name_3", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_count_1", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_count_2", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_count_3", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_index_1", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_index_2", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_index_3", Colors.strokeBrown, 1 )
end

function LegionHitEggItem:updateItem( startIndex )
	if type(startIndex) ~= "number" then 
		startIndex = 1 
	end
	
	local firstTreasureIndex = (startIndex - 1)*3 + 1
	local index = 1
	for loopi = firstTreasureIndex, firstTreasureIndex + 2 do 
		local awardInfo = G_Me.legionData:getAwardByIndex(loopi)
		self:showWidgetByName("Image_egg_piece_"..index, awardInfo and true or false)
		self:showWidgetByName("Button_egg_"..index, not awardInfo and true or false)
		self:showTextWithLabel("Label_player_name_"..index, awardInfo and awardInfo.name or "")
		--self:showTextWithLabel("Label_index_"..index, loopi)
		local bmpLabel = self:getLabelBMFontByName("BitmapLabel_"..index)
		if bmpLabel then 
			bmpLabel:setText(loopi)
		end
		if awardInfo then 
			local treasureInfo = corps_dungeon_award_info.get(awardInfo.id)
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

				
					self:registerWidgetClickEvent("Button_item_"..index, function ( ... )
						require("app.scenes.common.dropinfo.DropInfo").show(treasureInfo.item_type, treasureInfo.item_value) 
					end)
				end		
			end
		else
			self:registerWidgetClickEvent("Button_egg_"..index, function ( ... )
				self:_onEggClick(loopi)
			end)
		end
		
		index = index + 1
	end
end

function LegionHitEggItem:_onEggClick( eggIndex )
	if not G_Me.legionData:hasAwardRight() then 
		return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_HIT_EGG_NO_RIGHT"))
	end
	if not G_Me.legionData:haveFinishChapter() then 
		return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_HIT_EGG_NO_PERMIT"))
	end

	if G_Me.legionData:haveAcquireAward() then 
		return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_HIT_EGG_COMPLETE"))
	end

	if type(eggIndex) == "number" then 
		G_HandlersManager.legionHandler:sendGetDungeonAward(eggIndex)
	end
end

return LegionHitEggItem


