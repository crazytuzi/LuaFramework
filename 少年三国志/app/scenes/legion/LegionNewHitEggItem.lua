--LegionNewHitEggItem.lua

require("app.cfg.corps_dungeon_award_info")
local EffectNode = require "app.common.effects.EffectNode"

local LegionNewHitEggItem = class("LegionNewHitEggItem", function ( ... )
	return CCSItemCellBase:create("ui_layout/legion_DungeonNewEggItem.json")
end)

function LegionNewHitEggItem:ctor( ... )
	self:enableLabelStroke("Label_player_name_1", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_player_name_2", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_player_name_3", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_count_1", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_count_2", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_count_3", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_index_1", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_index_2", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_index_3", Colors.strokeBrown, 1 )
	self.effectNode = {}
end

function LegionNewHitEggItem:updateItem(dungeonId, startIndex )
	if type(startIndex) ~= "number" then 
		startIndex = 1 
	end
	self._dungeonId = dungeonId
	local firstTreasureIndex = (startIndex - 1)*3 + 1
	local index = 1
	for loopi = firstTreasureIndex, firstTreasureIndex + 2 do 
		local awardInfo = G_Me.legionData:getNewDungeonAwardByIndex(dungeonId,loopi)
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

function LegionNewHitEggItem:_onEggClick( eggIndex )
	if G_Me.legionData:getNewDungeonAwardHasGet(self._dungeonId) then 
		return G_MovingTip:showMovingTip(G_lang:get("LANG_NEW_LEGION_EGG_HAS_GOT"))
	end
	if not G_Me.legionData:haveNewFinishDungeon(self._dungeonId) then 
		return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_HIT_EGG_NO_PERMIT"))
	end

	if not G_Me.legionData:getNewDungeonAwardCanGet(self._dungeonId) then 
		return G_MovingTip:showMovingTip(G_lang:get("LANG_NEW_LEGION_EGG_CAN_NOT_GOT"))
	end

	if type(eggIndex) == "number" then 
		G_HandlersManager.legionHandler:sendGetNewDungeonAward(self._dungeonId,eggIndex)
	end
end

return LegionNewHitEggItem


