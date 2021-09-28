--MonthFundAwardPreviewItem.lua

require("app.cfg.month_fund_info")
require("app.cfg.month_fund_small_info")
local EffectNode = require "app.common.effects.EffectNode"

local MonthFundPreviewAwardItemNumPerLine = 4   --奖励预览列表每行显示奖励数目


local MonthFundAwardPreviewItem = class("MonthFundAwardPreviewItem", function ( ... )
	return CCSItemCellBase:create("ui_layout/monthfund_AwardPreviewItem.json")
end)

function MonthFundAwardPreviewItem:ctor( ... )

	self._roundEffects = {}

	for loopi = 1, MonthFundPreviewAwardItemNumPerLine do 
		self:enableLabelStroke("Label_count_"..loopi, Colors.strokeBrown, 1 )
		self:enableLabelStroke("Label_day_count_"..loopi, Colors.strokeBrown, 2 )
	end

end

function MonthFundAwardPreviewItem:updateItem( startIndex,_type )
	if type(startIndex) ~= "number" then 
		startIndex = 1 
	end

	local firstAwardIndex = (startIndex - 1)*MonthFundPreviewAwardItemNumPerLine + 1
	local index = 1
	for loopi = firstAwardIndex, firstAwardIndex + MonthFundPreviewAwardItemNumPerLine - 1 do 
		local awardInfo = _type == 1 and month_fund_small_info.get(loopi) or month_fund_info.get(loopi)

		self:showWidgetByName("Panel_item_"..index, awardInfo and true or false)
		if awardInfo ~= nil then 
			local goodInfo = G_Goods.convert(awardInfo.type, awardInfo.value, awardInfo.size)
	
			if goodInfo ~= nil then 
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

				self:showTextWithLabel("Label_count_"..index, "x"..GlobalFunc.ConvertNumToCharacter2(awardInfo.size))

				self:showTextWithLabel("Label_day_count_"..index,  G_lang:get("LANG_MONTH_FUND_AWARD_DAY", {num=loopi}) )

				self:registerWidgetClickEvent("Button_item_"..index, function ( ... )
					require("app.scenes.common.dropinfo.DropInfo").show(awardInfo.type, awardInfo.value) 
				end)

				if not self._roundEffects[index] then
					self._roundEffects[index] = EffectNode.new("effect_around1")
					self._roundEffects[index]:setScale(2)
					self._roundEffects[index]:play()
					self._roundEffects[index]:setPositionXY(63, 50)
					self:getPanelByName("Panel_item_"..index):addNode(self._roundEffects[index], 10)
				end

				self._roundEffects[index]:setVisible(awardInfo.add_effect == 1)
			end		
		end
		index = index + 1
	end
end

return MonthFundAwardPreviewItem


