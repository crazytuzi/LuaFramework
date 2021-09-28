local RCardMainLayer = class("RCardMainLayer",UFCCSNormalLayer)

local RCardSprite = require("app.scenes.dafuweng.RCardSprite")
local EffectNode = require "app.common.effects.EffectNode"

local FuCommon = require("app.scenes.dafuweng.FuCommon")
require("app.cfg.recharge_card_info")

RCardMainLayer.TYPE_NORMAL = 1
RCardMainLayer.TYPE_RICH = 2

RCardMainLayer.CARD_MAX = 8

-- function RCardMainLayer.create(...)
--     return RCardMainLayer.new("ui_layout/dafuweng_RechargeCard.json", ...)
-- end

function RCardMainLayer:ctor(...)

	self._tabs = require("app.common.tools.Tabs").new(2, self,self._checkedCallBack, self._uncheckedCallBack) 
	self._tabs:add("CheckBox_normal", nil, nil)
	self._tabs:add("CheckBox_rich", nil, nil)

	self._mainPanel = self:getPanelByName("Panel_middle")
	self._costPanel = self:getPanelByName("Panel_cost")
	self._clickPanel = self:getPanelByName("Panel_click")
	self._clickPanel:setVisible(false)

	self._checkedIndex = 1
	self._cards = {}
	self:initLabels()
	self:initCards()
	self._playingAnime = false

	self.buttonEffect = EffectNode.new("effect_around2", function(event, frameIndex)
	                  end)     
          	self.buttonEffect:setScale(1.5)    
	self.buttonEffect:play()
	self:getButtonByName("Button_xipai"):addNode( self.buttonEffect,10)
	self.buttonEffect:setPositionXY(0,0)
	self.buttonEffect:setVisible(false)

	self:registerBtnClickEvent("Button_return", function()
		self:onBackKeyEvent()
	end)
	self:registerBtnClickEvent("Button_help", function()
		require("app.scenes.common.CommonHelpLayer").show({
		    {title=G_lang:get("LANG_RCARD_HELP_TITLE1"), content=G_lang:get("LANG_RCARD_HELP_CONTENT1")},
		    {title=G_lang:get("LANG_RCARD_HELP_TITLE2"), content=G_lang:get("LANG_RCARD_HELP_CONTENT2")},
		    } )
	end)
	self:registerBtnClickEvent("Button_recharge", function()
		require("app.scenes.shop.recharge.RechargeLayer").show()
	end)
	self:registerBtnClickEvent("Button_xipai", function()
		self:reset()
	end)
	self:registerBtnClickEvent("Button_preview", function()
		require("app.scenes.dafuweng.RCardAwardLayer").show(self._checkedIndex)
	end)

	self.super.ctor(self,...)
end

function RCardMainLayer:onBackKeyEvent( ... )
	local packScene = G_GlobalFunc.createPackScene(self)
	if packScene then 
		uf_sceneManager:replaceScene(packScene)
	else		
		GlobalFunc.popSceneWithDefault("app.scenes.dafuweng.FuMainScene",FuCommon.RECHARGE_TYPE_ID)
	end

	return true
end

function RCardMainLayer:_checkedCallBack(btnName)
	if btnName == "CheckBox_normal" then
		self._checkedIndex = RCardMainLayer.TYPE_NORMAL
	elseif btnName == "CheckBox_rich" then
		self._checkedIndex = RCardMainLayer.TYPE_RICH
	end
	self:updateView()
	self:moveInAnime()
end

function RCardMainLayer:onLayerEnter()
	self:registerKeypadEvent(true)
	self._tabs:checked("CheckBox_normal")
	self._checkedIndex = RCardMainLayer.TYPE_NORMAL
	self._playingAnime = false

	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RCARDINFO, self.updateView, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RCARDPLAY, self._onRCardPlay, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RCARDRESET, self._onRCardReset, self)

	G_HandlersManager.rCardHandler:sendRCardInfo()
	self:_refreshTimeLeft()
	if self._schedule == nil then
		self._schedule = GlobalFunc.addTimer(1, handler(self, self._refreshTimeLeft))
	end
end

function RCardMainLayer:_refreshTimeLeft()
	local time = G_Me.rCardData:getTimeLeft()
	if time < 0 then
		if self._schedule then
			GlobalFunc.removeTimer(self._schedule)
			self._schedule = nil
		end
		uf_sceneManager:replaceScene(require("app.scenes.dafuweng.FuMainScene").new(FuCommon.RECHARGE_TYPE_ID))
	    	return
	end
	self._timeLabel:setText(G_GlobalFunc.formatTimeToHourMinSec(time))
end

function RCardMainLayer:onLayerExit()
	if self._schedule then
	    GlobalFunc.removeTimer(self._schedule)
	    self._schedule = nil
	end
end

function RCardMainLayer:updateView()
	if not G_Me.rCardData:isOpen() then
		uf_sceneManager:replaceScene(require("app.scenes.dafuweng.FuMainScene").new(FuCommon.RECHARGE_TYPE_ID))
		return
	end
	self:updateLabels()
	self:updateCards()
end

function RCardMainLayer:moveInAnime( )
	local delay = 0.1
	for i = RCardMainLayer.CARD_MAX/2 , 1 , -1 do 
		GlobalFunc.flyIntoScreenLR({self._cards[i].node}, true, delay, 2, 10)
		delay = delay + 0.1
	end
	delay = 0.1
	for i = RCardMainLayer.CARD_MAX/2+1 , RCardMainLayer.CARD_MAX do 
		GlobalFunc.flyIntoScreenLR({self._cards[i].node}, false, delay, 2, 10)
		delay = delay + 0.1
	end
end

function RCardMainLayer:initLabels()
	self._scoreLabel = self:getLabelByName("Label_score")
	self._scoreLabel:createStroke(Colors.strokeBrown,1)
	self:getLabelByName("Label_scoreTitle"):createStroke(Colors.strokeBrown,1)
	self:getLabelByName("Label_txt"):createStroke(Colors.strokeBrown,1)
	self:getLabelByName("Label_txt"):setText(G_lang:get("LANG_RCARD_TIPS")) 
	self._timeLabel = self:getLabelByName("Label_time")
	self._timeLabel:createStroke(Colors.strokeBrown,1)
	self:getLabelByName("Label_timeTitle"):createStroke(Colors.strokeBrown,1)
	self._costScoreLabel = self:getLabelByName("Label_costScore")
	self._costScoreLabel:createStroke(Colors.strokeBrown,1)
	self._costLabel = self:getLabelByName("Label_cost")
	self._costLabel:createStroke(Colors.strokeBrown,1)
	self:getLabelByName("Label_costTitle"):createStroke(Colors.strokeBrown,1)
	self:getLabelByName("Label_leftTime1"):createStroke(Colors.strokeBrown,1)
	self:getLabelByName("Label_leftTime2"):createStroke(Colors.strokeBrown,1)
	self._leftTimesLabel = self:getLabelByName("Label_leftTime")
	self._leftTimesLabel:createStroke(Colors.strokeBrown,1)
	self:getLabelByName("Label_leftTime3"):createStroke(Colors.strokeBrown,1)
	self._tipsLabel = self:getLabelByName("Label_tips")
	self._tipsLabel:createStroke(Colors.strokeBrown,1)
	self._tipsPanel = self:getPanelByName("Panel_tips")
	self._btnImg = self:getImageViewByName("Image_btn")

	local lx,ly = self._tipsLabel:getPosition()
	self._tipsLabel:setPositionXY(lx,ly-self:getOffset()*1.5+38)
	local px,py = self._tipsPanel:getPosition()
	self._tipsPanel:setPositionXY(px,py-self:getOffset()*1.5+38)
end

function RCardMainLayer:updateLabels()
	self._scoreLabel:setText(G_Me.rCardData:getCurScore())
	local cost = G_Me.rCardData:curResetCost(self._checkedIndex)
	self._costLabel:setText(math.max(cost,0))
	self._leftTimesLabel:setText(G_Me.rCardData:getLeftCostTimes(self._checkedIndex)) 
	self._costScoreLabel:setText(G_Me.rCardData:costScore(self._checkedIndex))
	local first = G_Me.rCardData:isFirst(self._checkedIndex)
	self._costPanel:setVisible(not first)
	self._tipsLabel:setVisible(first)
	self._tipsPanel:setVisible(not first)
	local btnUrl = first and "ui/text/txt-middle-btn/xipai.png" or "ui/text/txt-middle-btn/chongzhi_red.png"
	self._btnImg:loadTexture(btnUrl)

	local shouldReset = (not G_Me.rCardData:canFlip(self._checkedIndex)) and cost>=0
	self.buttonEffect:setVisible(shouldReset or G_Me.rCardData:isFirst(self._checkedIndex))
end

function RCardMainLayer:initCards()
	local edge = 20
	local width = 640
	local height = 350
	local yOffset = 50
	for i = 1, RCardMainLayer.CARD_MAX do 
		local card = RCardSprite:new()
		self._cards[i] = card
		card:setIndex(i)
		card:setZTag(10+i)
		self._mainPanel:addChild(card.node,10+i)
		card:registerTouchEvent(self,function ( )
			self:clickCard(i)
		end)
		card:setBasePositionXY(edge+(width-edge*2)/8*(((i-1)%4)*2+1),yOffset + height/4*((1-math.floor((i-1)/4))*2+1)-self:getOffset()*((math.floor((i-1)/4))-0.5)*2)
	end
end

function RCardMainLayer:clickCard(index)
	if self._playingAnime then
		return
	end
	local leftTimes = G_Me.rCardData:getLeftCostTimes(self._checkedIndex)
	if leftTimes <= 0 then
		G_MovingTip:showMovingTip(G_lang:get("LANG_FU_CARD_EMPTY"))
		return 
	end
	if not G_Me.rCardData:getCurAward(self._checkedIndex,index) then
		if G_Me.rCardData:getCurScore() >= G_Me.rCardData:costScore(self._checkedIndex) then
			G_HandlersManager.rCardHandler:sendPlayRCard(self._checkedIndex,index-1)
		else
			local str = G_lang:get("LANG_FU_CARD_SCORE_NOT_ENOUGH")
			MessageBoxEx.showYesNoMessage(nil,str,false,function()
			    require("app.scenes.shop.recharge.RechargeLayer").show()  
			end,nil,nil,MessageBoxEx.OKNOButton.OKNOBtn_Vip)
		end
	end
end

function RCardMainLayer:reset()
	if self._playingAnime then
		return
	end
	if G_Me.rCardData:isFirst(self._checkedIndex) then
		G_Me.rCardData:storeFirst(self._checkedIndex)
		self:updateLabels()
		self:resetAnime()
	else
		local leftTimes = G_Me.rCardData:getLeftCostTimes(self._checkedIndex)
		if leftTimes <= 0 then
			G_MovingTip:showMovingTip(G_lang:get("LANG_FU_CARD_EMPTY"))
			return 
		end
		local cost = G_Me.rCardData:curResetCost(self._checkedIndex)
		if cost < 0 then
			G_MovingTip:showMovingTip(G_lang:get("LANG_FU_CARD_EMPTY"))
			return 
		end
		if cost > G_Me.userData.gold then
			require("app.scenes.shop.GoldNotEnoughDialog").show()
			return 
		end
		if not G_Me.rCardData:canReset(self._checkedIndex) then
			G_MovingTip:showMovingTip(G_lang:get("LANG_FU_CARD_SHOULD_FLIP"))
			return 
		end
		MessageBoxEx.showYesNoMessage(nil, 
		            G_lang:get("LANG_FU_CARD_XIPAI",{gold=cost}), false, 
		            function ( ... )
		                G_HandlersManager.rCardHandler:sendResetRCard(self._checkedIndex)
		            end)
	end
end

function RCardMainLayer:resetAnime()
	self:playingAnime(true)

	local count = 0
	local callBack = function ( )
		count = count + 1 
		if count == RCardMainLayer.CARD_MAX then
			-- self:playingAnime(false)
			-- self:updateView()
			self:moveAnime()
		end
	end

	for i = 1 , RCardMainLayer.CARD_MAX do 
		self._cards[i]:flip(self._checkedIndex,false,callBack)
	end
	
end

function RCardMainLayer:moveAnime()
	local count = 0
	local callBack = function ( )
		count = count + 1 
		if count == RCardMainLayer.CARD_MAX then
			self:playingAnime(false)
			self:updateView()
		end
	end
	local count2 = 0
	local calls = {}
	local playEffect = function ( callBack)
		count2 = count2 + 1 
		calls[count2] = callBack
		if count2 == RCardMainLayer.CARD_MAX then
			self._effect = EffectNode.new("effect_xipai",function(event, frameIndex)
			        if event == "finish" then
			        	for k , v in pairs(calls) do
			        		v()
			        	end
			            	self._effect:removeFromParentAndCleanup(true)
			        end
			    end
			)      
			self._effect:play()
			self._mainPanel:addNode( self._effect,50)
			self._effect:setPositionXY(340,250)
		end
	end

	for i = 1 , RCardMainLayer.CARD_MAX do 
		self._cards[i]:move(self:getOffset(),callBack,playEffect)
	end
end

function RCardMainLayer:updateCards()
	local info = recharge_card_info.get(self._checkedIndex)
	if G_Me.rCardData:isFirst(self._checkedIndex) then
		for i = 1 , RCardMainLayer.CARD_MAX do 
			local data = {type=info["type_"..i],value=info["value_"..i],size=info["size_"..i],light=info["if_effect_"..i]}
			self._cards[info["position_"..i]]:updateData(self._checkedIndex,data)
		end
	else
		for i = 1 , RCardMainLayer.CARD_MAX do 
			local id = G_Me.rCardData:getCurAward(self._checkedIndex,i)
			if id then
				local data = {type=info["type_"..id],value=info["value_"..id],size=info["size_"..id],light=info["if_effect_"..id]}
				self._cards[i]:updateData(self._checkedIndex,data)
			else
				self._cards[i]:updateData(self._checkedIndex)
			end
		end
	end
end

function RCardMainLayer:playingAnime(flag)
	self._playingAnime = flag
	self._clickPanel:setVisible(flag)
end

function RCardMainLayer:_onRCardPlay(data)
	-- self:updateView()
	local pos = data.pos+1
	local awardIndex = data.cid+1
	local info = recharge_card_info.get(self._checkedIndex)
	local award = {type=info["type_"..awardIndex],value=info["value_"..awardIndex],size=info["size_"..awardIndex],light=info["if_effect_"..awardIndex]}
	local callBack = function ( )
		local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create({award})
		uf_notifyLayer:getModelNode():addChild(_layer,1000)
		self:playingAnime(false)
		self:updateView()
	end
	self._cards[pos]:updateData(self._checkedIndex,award)
	self._cards[pos]:hideAward(self._checkedIndex)
	self._cards[pos]:flip(self._checkedIndex,true,callBack)
end

function RCardMainLayer:_onRCardReset()
	-- self:updateView()
	self:updateLabels()
	self:resetAnime()
end

function RCardMainLayer:getOffset()
	return (display.height-853)/6
end

return RCardMainLayer
