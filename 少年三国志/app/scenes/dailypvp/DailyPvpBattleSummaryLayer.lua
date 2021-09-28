local DailyPvpBattleSummaryLayer = class("DailyPvpBattleSummaryLayer", UFCCSModelLayer)
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
require("app.cfg.daily_crosspvp_rank_title")

function DailyPvpBattleSummaryLayer:ctor(json,color,heroData,winnerData,winData,win,callback)
    self.super.ctor(self,json)
    self._heroData = heroData
    self._winnerData = winnerData
    self._winData = winData
    self._win = win
    self._callBack = callback
    self._clickClose = false
    self:showAtCenter(true)
    self:setClickClose(true)
    self:registerTouchEvent(false,true,0)
end

function DailyPvpBattleSummaryLayer.create(heroData,winnerData,winData,win,callback)
    local layer = DailyPvpBattleSummaryLayer.new("ui_layout/dailypvp_Summary.json",ccc4(0, 0, 0, 220),heroData,winnerData,winData,win,callback) 
    return layer
end

function DailyPvpBattleSummaryLayer:onLayerEnter()
    self:closeAtReturn(true)
    EffectSingleMoving.run(self, "smoving_bounce")
    self:getImageViewByName("Image_click_continue"):setVisible(false)
    self:updateView()
    self:enterAnime()
end

function DailyPvpBattleSummaryLayer:enterAnime()
	local delay = 0.2
	for i = 1 , 5 do 
		GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Panel_up_"..i)}, true, delay, 2, 100)
		delay = delay + 0.1
	end
	for i = 1 , 5 do 
		GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Panel_down_"..i)}, true, delay, 2, 100)
		delay = delay + 0.1
	end

	local icon1 = self:getImageViewByName("Image_result_icon_up")
	local icon2 = self:getImageViewByName("Image_result_icon_down")
	icon1:setVisible(false)
	icon2:setVisible(false)
	local seqArr = CCArray:create()
	seqArr:addObject(CCDelayTime:create(delay))
	seqArr:addObject(CCCallFunc:create(function()
	    icon1:setVisible(true)
	    icon2:setVisible(true)
	    icon1:setScale(5.0)
	    icon2:setScale(5.0)
	    local scaleAction1 = CCScaleTo:create(0.3,1)
	    local scaleAction2 = CCScaleTo:create(0.3,1)
	    icon1:runAction(CCEaseBackOut:create(scaleAction1))
	    icon2:runAction(CCEaseBackOut:create(scaleAction2))
	end))
	seqArr:addObject(CCDelayTime:create(0.3))
	seqArr:addObject(CCCallFunc:create(function()
		self._clickClose = true
		self:getImageViewByName("Image_click_continue"):setVisible(true)
		EffectSingleMoving.run(self:getImageViewByName("Image_click_continue"), "smoving_wait", nil , {position = true} )
	end))
	self:runAction(CCSequence:create(seqArr))
end

function DailyPvpBattleSummaryLayer:updateView()
	local getKillNumber = function ( data )
		for k , v in pairs(self._winData) do 
			if data.id == v.data.uid and data.sid == v.data.sid then
				return v.count
			end
		end
		return 0
	end
	local isMvp = function ( data )
		for k , v in pairs(self._winnerData) do 
			if data.id == v.uid and data.sid == v.sid then
				return true
			end
		end
	end
    for i = 1 , 2 do 
    	local dir = i == 1 and "up" or "down"
    	local win = (i == 1 and self._win) or (i == 2 and not self._win)
    	self:getImageViewByName("Image_result_icon_"..dir):loadTexture(win and "ui/text/txt/shengli.png" or "ui/text/txt/shibai.png")
    	for k , v in pairs(self._heroData[i]) do 
    		local pos = v.sp3+1
    		local nameLabel = self:getLabelByName("Label_"..dir.."_name_"..pos)
    		local titleLabel = self:getLabelByName("Label_"..dir.."_title_"..pos)
    		local numberLabel = self:getLabelByName("Label_"..dir.."_number_"..pos)
    		
    		local titleId = v.sp6
    		titleId = (titleId and titleId > 0) and titleId or 7
    		local titleInfo = daily_crosspvp_rank_title.get(titleId)
    		local name = v.name.."[" .. string.gsub(v.sname, "^.-%((.-)%)", "%1") .. "]"
    		nameLabel:setText(name)
    		titleLabel:setText(titleInfo.text)
    		titleLabel:setColor(Colors.qualityColors[titleInfo.quality])
    		numberLabel:setText(getKillNumber(v))

    		local mvp = isMvp(v)
    		nameLabel:setColor(mvp and Colors.darkColors.TITLE_01 or Colors.darkColors.DESCRIPTION)
    		numberLabel:setColor(mvp and Colors.darkColors.TITLE_01 or Colors.darkColors.DESCRIPTION)
    	end
    end
end

function DailyPvpBattleSummaryLayer:onLayerExit()
	
end

function DailyPvpBattleSummaryLayer:onClickClose( ... )
	if self._clickClose then
		if self._callBack then
			self._callBack()
		end
		self:close()
	end
	return true
end

return DailyPvpBattleSummaryLayer