--MonthFundAwardItem.lua

require("app.cfg.month_fund_info")
require("app.cfg.month_fund_small_info")

local MonthFundAwardItemNumPerLine = 5

local EffectNode = require "app.common.effects.EffectNode"

local MonthFundAwardItem = class("MonthFundAwardItem", function ( ... )
	return CCSItemCellBase:create("ui_layout/monthfund_AwardItem.json")
end)

function MonthFundAwardItem:ctor( ... )

    self._roundEffect = {}

	for loopi = 1, MonthFundAwardItemNumPerLine do 
		self:enableLabelStroke("Label_count_"..loopi, Colors.strokeBrown, 1 )
		self:enableLabelStroke("Label_day_count_"..loopi, Colors.strokeBrown, 2 )
	end
end

function MonthFundAwardItem:updateItem( startIndex,_type, func )
	if type(startIndex) ~= "number" then 
		startIndex = 1 
	end

	local firstAwardIndex = (startIndex - 1)*MonthFundAwardItemNumPerLine + 1
	local index = 1

	for loopi = firstAwardIndex, firstAwardIndex + MonthFundAwardItemNumPerLine - 1 do 
		local awardInfo = _type == 1 and month_fund_small_info.get(loopi) or month_fund_info.get(loopi)  --FIXME

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

				local boughtImage = self:getImageViewByName("Image_choose"..index)
				if boughtImage then
		        	boughtImage:setVisible(false)
		        end

				if G_Me.monthFundData:hasBought(_type) and G_Me.monthFundData:canGetAward(loopi,_type) then
		        	self:_addRoundEffect(index)
		        elseif G_Me.monthFundData:hasGetAward(loopi,_type) then
		        	self:_removeRoundEffect(index)
		        	if boughtImage then
		        		boughtImage:setVisible(true)
		        	end
		        else
		        	self:_removeRoundEffect(index)		    
		        end

				self:registerWidgetClickEvent("Button_item_"..index, function ()
			        
					if G_Me.monthFundData:hasBought(_type) then
						if G_Me.monthFundData:canGetAward(loopi,_type) then
							if func then
			            		func(awardInfo.id)
			        		end
			        		G_HandlersManager.monthFundHandler:sendGetMonthFundAward(loopi,3 - _type)
			        	--elseif G_Me.monthFundData:getEndAwardCountDown() <= 0 then
			        		--G_MovingTip:showMovingTip(G_lang:get("LANG_MONTH_FUND_STOP_AWARD"))		        	
			        	else
			        		require("app.scenes.common.dropinfo.DropInfo").show(awardInfo.type, awardInfo.value)
			        	end
			        else
			        	--G_MovingTip:showMovingTip(G_lang:get("LANG_MONTH_FUND_BUY_TIPS"))
			        	require("app.scenes.common.dropinfo.DropInfo").show(awardInfo.type, awardInfo.value)
			        end
				end)
			end		
		end
		index = index + 1
	end
end


function MonthFundAwardItem:_addRoundEffect(index)

    self:_removeRoundEffect(index)
    if self._roundEffect[index] == nil then
        self._roundEffect[index] = EffectNode.new("effect_around1", function(event, frameIndex)
        	end)     
        self._roundEffect[index]:setScale(1.6)
        self._roundEffect[index]:play()
        self._roundEffect[index]:setPosition(ccp(53,46))
        self:getPanelByName("Panel_effect_"..index):addNode(self._roundEffect[index])
    end 
end

function MonthFundAwardItem:_removeRoundEffect(index)

    if self._roundEffect[index] ~= nil then
        self._roundEffect[index]:removeFromParentAndCleanup(true)
        self._roundEffect[index] = nil
    end
end

return MonthFundAwardItem


