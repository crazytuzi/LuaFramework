local DailyPvpTipsLayer = class("DailyPvpTipsLayer", UFCCSModelLayer)
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
require("app.cfg.shop_price_info")

DailyPvpTipsLayer.WIN = 100
DailyPvpTipsLayer.LOSE = 50

function DailyPvpTipsLayer.create()
   return DailyPvpTipsLayer.new("ui_layout/dailypvp_Tips.json", require("app.setting.Colors").modelColor)
end

function DailyPvpTipsLayer:ctor(...)
    self.super.ctor(self,...)
    self:showAtCenter(true)

    self._tipCheck = self:getCheckBoxByName("CheckBox_tips")
    self:registerCheckboxEvent("CheckBox_tips", function( widget, type, isCheck )
        G_Me.dailyPvpData:setShowTips(not isCheck)
        self:updateCheck()
    end)
    
    self:registerBtnClickEvent("Button_cancel",function()
        if self._callBack then
            self._callBack()
        end
        self:animationToClose()
    end)
    self:registerBtnClickEvent("Button_ok",function()
        self:buyTimes()
        self:animationToClose()
    end)
end

function DailyPvpTipsLayer:setCancelImg(img)
    if img then
        self:getImageViewByName("Image_cancel"):loadTexture(img)
    end
end

function DailyPvpTipsLayer:setCancelCallBack(callBack)
    self._callBack = callBack
end

function DailyPvpTipsLayer:onLayerEnter()
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TEAMPVPBUYAWARDCNT, self.buyFinish, self)
	self:closeAtReturn(true)
	EffectSingleMoving.run(self, "smoving_bounce")
	self:updateView()
	self:updateCheck()
end

function DailyPvpTipsLayer:buyFinish()
	self:animationToClose()
end

function DailyPvpTipsLayer:updateCheck()
	local check = G_Me.dailyPvpData:getShowTips()
	self._tipCheck:setSelectedState(not check)
end

function DailyPvpTipsLayer:updateView()
	local scoreData = G_Me.dailyPvpData:getBaseScore()
	self:getLabelByName("Label_score1"):setText(scoreData.award_win)
	self:getLabelByName("Label_score2"):setText(scoreData.award_failure)
	local specialTime = G_Me.dailyPvpData:inSpecialTime()
	self:getLabelByName("Label_rongyu1"):setText(specialTime>0 and DailyPvpTipsLayer.WIN*2 or DailyPvpTipsLayer.WIN)
	self:getLabelByName("Label_rongyu2"):setText(specialTime>0 and DailyPvpTipsLayer.LOSE*2 or DailyPvpTipsLayer.LOSE)
	self:getLabelByName("Label_tips"):createStroke(Colors.strokeBrown, 1)
end

function DailyPvpTipsLayer:onLayerExit()
	
end

function DailyPvpTipsLayer:buyTimes()
    local priceData = shop_price_info.get(31,G_Me.dailyPvpData:getBuyCount()+1)
    if not priceData then
        G_MovingTip:showMovingTip(G_lang:get("LANG_DAILY_BUY_OVER"))
        return
    end
    local price = priceData.price
    if G_Me.userData.gold < price then
        require("app.scenes.shop.GoldNotEnoughDialog").show()
        return
    else
        MessageBoxEx.showYesNoMessage(nil, 
                    G_lang:get("LANG_DAILY_BUY_TIMES",{gold=price}), false, 
                    function ( ... )
                        G_HandlersManager.dailyPvpHandler:sendTeamPVPBuyAwardCnt()
                    end)
    end
end

return DailyPvpTipsLayer