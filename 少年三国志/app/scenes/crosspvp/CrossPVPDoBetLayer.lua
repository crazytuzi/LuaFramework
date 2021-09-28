
require("app.cfg.knight_info")
require("app.cfg.crosspvp_flower_award_info")

local CommonFunc = require("app.scenes.moshen.rebelboss.RebelBossCommonFunc")
local CrossPVPConst = require("app.const.CrossPVPConst")
local CrossPVPCommon = require("app.scenes.crosspvp.CrossPVPCommon")
local CrossPVPBetBuyPanel = require("app.scenes.crosspvp.CrossPVPBetBuyPanel")

local CrossPVPDoBetLayer = class("CrossPVPDoBetLayer", UFCCSModelLayer)

function CrossPVPDoBetLayer.create(caller)
	return CrossPVPDoBetLayer.new("ui_layout/crosspvp_DoBetLayer.json", Colors.modelColor, caller)
end

function CrossPVPDoBetLayer:ctor(json, color, caller)
	self._caller 			= caller
	self._flowerTarget 		= G_Me.crossPVPData:getFlowerTarget()
	self._eggTarget 		= G_Me.crossPVPData:getEggTarget()
	self._bUpdateBet 		= false
	self._bUpdateBetAward 	= false
	self.super.ctor(self, json, color)
end

function CrossPVPDoBetLayer:onLayerLoad()
	self:_initTabs()
	self:_initWidgets()
	self:_registerButtons()
end

function CrossPVPDoBetLayer:onLayerEnter()
	self:showAtCenter(true)
	self:closeAtReturn(true)

	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_Bg"), "smoving_bounce")

	self._tabs:checked("CheckBox_Bet")

	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_PVP_BET_FINISH, self._onRcvBet, self)

	-- countdown
	self:_createTimer()
end

function CrossPVPDoBetLayer:onLayerExit()
	self:_removeTimer()
end

function CrossPVPDoBetLayer:_createTimer()
	if not self._timer then
		self:_updateBetEndTime()
		self._timer = G_GlobalFunc.addTimer(1, handler(self, self._updateBetEndTime))
	end
end

function CrossPVPDoBetLayer:_removeTimer()
	if self._timer then
		G_GlobalFunc.removeTimer(self._timer)
		self._timer = nil
	end
end

function CrossPVPDoBetLayer:_updateBetEndTime()
	local _, betEndTime = G_Me.crossPVPData:getStageTime(CrossPVPConst.STAGE_BET)
	local leftTime = CrossPVPCommon.getFormatLeftTime(betEndTime)
	if leftTime == "" then
		self:_removeTimer()
		self:_closeWindow()
	else
		self:showTextWithLabel("Label_BetFinish_Time", leftTime)
	end
end

function CrossPVPDoBetLayer:_initTabs()
	self._tabs = require("app.common.tools.Tabs").new(1, self, self._onTabChecked, self._onTabUnchecked)
	self._tabs:add("CheckBox_Bet", self:getPanelByName("Panel_Bet"), "Label_Bet")
	self._tabs:add("CheckBox_BetAward", self:getPanelByName("Panel_BetAward"), "Label_BetAward")
end

function CrossPVPDoBetLayer:_initWidgets()
	CommonFunc._updateLabel(self, "Label_Title_BetFlower", {stroke=Colors.strokeBrown})
	CommonFunc._updateLabel(self, "Label_Title_BetEgg", {stroke=Colors.strokeBrown})
	CommonFunc._updateLabel(self, "Label_PlayerName_F", {stroke=Colors.strokeBrown})
	CommonFunc._updateLabel(self, "Label_PlayerName_E", {stroke=Colors.strokeBrown})
	CommonFunc._updateLabel(self, "Label_Title_AwardRule", {stroke=Colors.strokeBrown})
	CommonFunc._updateLabel(self, "Label_Title_Flower", {stroke=Colors.strokeBrown})
	CommonFunc._updateLabel(self, "Label_Title_Egg", {stroke=Colors.strokeBrown})
	CommonFunc._updateLabel(self, "Label_BetFinish", {stroke=Colors.strokeBrown})
	CommonFunc._updateLabel(self, "Label_BetFinish_Time", {stroke=Colors.strokeBrown})
	CommonFunc._updateLabel(self, "Label_AwardContent", {text=G_lang:get("LANG_CROSS_PVP_BET_AWARD_RULE")})

	-- let the "add" button blink
	local fadeIn = CCFadeIn:create(1.5)
	local fadeOut = CCFadeOut:create(1.5)
	local seq = CCSequence:createWithTwoActions(fadeIn, fadeOut)
	self:getWidgetByName("Image_Add_F"):runAction(CCRepeatForever:create(seq))

	local fadeIn = CCFadeIn:create(1.5)
	local fadeOut = CCFadeOut:create(1.5)
	local seq = CCSequence:createWithTwoActions(fadeIn, fadeOut)
	self:getWidgetByName("Image_Add_E"):runAction(CCRepeatForever:create(seq))
end

function CrossPVPDoBetLayer:_registerButtons()
	self:registerBtnClickEvent("Button_Add_F", handler(self, self._onClickSelect))
	self:registerBtnClickEvent("Button_Add_E", handler(self, self._onClickSelect))
	self:registerBtnClickEvent("Button_QualityFrame_F", handler(self, self._onClickSelect))
	self:registerBtnClickEvent("Button_QualityFrame_E", handler(self, self._onClickSelect))
	self:registerBtnClickEvent("Button_Bet_F", handler(self, self._onClickBet))
	self:registerBtnClickEvent("Button_Bet_E", handler(self, self._onClickBet))
	self:registerBtnClickEvent("Button_Close", handler(self, self._closeWindow))
	self:registerBtnClickEvent("Button_Close_TopRight", handler(self, self._closeWindow))
end

function CrossPVPDoBetLayer:_onTabChecked(szCheckBoxName)
	if szCheckBoxName == "CheckBox_Bet" then
		if not self._bUpdateBet then
			self:_updateBetTarget(CrossPVPConst.BET_FLOWER)
			self:_updateBetTarget(CrossPVPConst.BET_EGG)
			self._bUpdateBet = true
		end
	elseif szCheckBoxName == "CheckBox_BetAward" then
		if not self._bUpdateBetAward then
			self:_updateBetAwardPage()
			self._bUpdateBetAward = true
		end
	end
end

function CrossPVPDoBetLayer:_onClickSelect(widget)
	local selType = widget:getTag()
	local isAlreadyBet = false

	-- check if you've already bet a player
	if selType == CrossPVPConst.BET_FLOWER then
		isAlreadyBet = self._flowerTarget and self._flowerTarget.betByMe > 0
	else
		isAlreadyBet = self._eggTarget and self._eggTarget.betByMe > 0
	end

	-- if already bet a player, cannot change the target
	-- or, open the selecting layer
	if isAlreadyBet then
		G_MovingTip:showMovingTip(G_lang:get("LANG_CROSS_PVP_ALREADY_BET"))
	else
		self:_openSelectPlayerLayer(selType)
	end
end

function CrossPVPDoBetLayer:_onClickBet(widget)
	local betType = widget:getTag()
	local target = betType == CrossPVPConst.BET_FLOWER and self._flowerTarget or self._eggTarget

	if not target then
		return
	elseif target.betByMe <= 0 then
		local msg = G_lang:get("LANG_CROSS_PVP_CONFIRM_BET", {user = target.name})
		MessageBoxEx.showYesNoMessage(nil, msg, false, function() CrossPVPBetBuyPanel.show(betType, target) end,
									  nil, nil)
	else
		CrossPVPBetBuyPanel.show(betType, target)
	end
end

function CrossPVPDoBetLayer:_onTabUnchecked()
	
end

function CrossPVPDoBetLayer:_closeWindow()
	self:animationToClose()
end

function CrossPVPDoBetLayer:_onRcvBet(data)
	if data.type == CrossPVPConst.BET_FLOWER then
		self._flowerTarget.betByMe = self._flowerTarget.betByMe + data.count
		self._flowerTarget.totalBet = self._flowerTarget.totalBet + data.count
		G_Me.crossPVPData:updateBetTarget(self._flowerTarget, G_Me.crossPVPData:getEggTarget())

		self:showTextWithLabel("Label_GetBet_Value_F", tostring(self._flowerTarget.totalBet))
		self:showTextWithLabel("Label_MyBetNum_F", tostring(G_Me.crossPVPData:getNumBetFlower()))
	elseif data.type == CrossPVPConst.BET_EGG then
		self._eggTarget.betByMe = self._eggTarget.betByMe + data.count
		self._eggTarget.totalBet = self._eggTarget.totalBet + data.count
		G_Me.crossPVPData:updateBetTarget(G_Me.crossPVPData:getFlowerTarget(), self._eggTarget)

		self:showTextWithLabel("Label_GetBet_Value_E", tostring(self._eggTarget.totalBet))
		self:showTextWithLabel("Label_MyBetNum_E", tostring(G_Me.crossPVPData:getNumBetEgg()))
	end

	if self._caller and self._caller._onRcvBet then
		self._caller:_onRcvBet(data)
	end
end

function CrossPVPDoBetLayer:_updateBetTarget(betType)
	local isBetFlower = betType == CrossPVPConst.BET_FLOWER
	local postFix = isBetFlower and "_F" or "_E"
	local target  = nil

	if isBetFlower then target = self._flowerTarget
	else target = self._eggTarget end

	self:showWidgetByName("Panel_HasTarget" .. postFix, target ~= nil)
	self:showWidgetByName("Panel_NoTarget" .. postFix, not target)

	if target then
		local knightInfo = knight_info.get(target.main_role)
		-- set head icon
		local resID = G_Me.dressData:getDressedResidWithClidAndCltm(target.main_role, target.dress_id,
			rawget(target,"clid"),rawget(target,"cltm"),rawget(target,"clop"))

		self:getImageViewByName("Image_Icon" .. postFix):loadTexture(G_Path.getKnightIcon(resID))

		-- quality frame
		local qualityTex = G_Path.getEquipColorImage(knightInfo.quality, G_Goods.TYPE_KNIGHT)
		self:getButtonByName("Button_QualityFrame" .. postFix):loadTextureNormal(qualityTex, UI_TEX_TYPE_PLIST)

		-- user name
		local nameLabel = self:getLabelByName("Label_PlayerName" .. postFix)
		nameLabel:setText(target.name)
		nameLabel:setColor(Colors.qualityColors[knightInfo.quality])

		-- server name
		self:showTextWithLabel("Label_ServerName" .. postFix, tostring(target.sname))

		-- last rank
		self:showTextWithLabel("Label_LastRank_Value" .. postFix, tostring(target.lastRank))

		-- target's flower or egg number
		self:showTextWithLabel("Label_GetBet_Value" .. postFix, tostring(target.totalBet))

		-- flower or egg bet by me
		local myBetNum = isBetFlower and G_Me.crossPVPData:getNumBetFlower() or G_Me.crossPVPData:getNumBetEgg()
		self:showTextWithLabel("Label_MyBetNum" .. postFix, tostring(myBetNum))
	end
end

function CrossPVPDoBetLayer:_openSelectPlayerLayer(selType)
	-- selection callback
	-- @param data: data of the selected user
	local callback = function(data)
		local curTarget, anotherTarget, anotherType

		-- update current betting target
		curTarget = clone(data)
		curTarget.lastRank = rawget(data, "sp2") or 0
		curTarget.betByMe  = 0

		if selType == CrossPVPConst.BET_FLOWER then
			curTarget.totalBet = rawget(data, "sp3") or 0
		else
			curTarget.totalBet = rawget(data, "sp4") or 0
		end

		if selType == CrossPVPConst.BET_FLOWER then
			self._flowerTarget = curTarget
			anotherTarget = self._eggTarget
			anotherType = CrossPVPConst.BET_EGG
		else
			self._eggTarget = curTarget
			anotherTarget = self._flowerTarget
			anotherType = CrossPVPConst.BET_FLOWER
		end
		self:_updateBetTarget(selType)

		-- if current target covers another target
		if anotherTarget and anotherTarget.betByMe <= 0 and
		   tostring(anotherTarget.id) == tostring(curTarget.id) and
		   tostring(anotherTarget.sid) == tostring(curTarget.sid) then
		   if selType == CrossPVPConst.BET_FLOWER then
		   		self._eggTarget = nil
		   else
		   		self._flowerTarget = nil
		   end
		   self:_updateBetTarget(anotherType)
		end
	end

	local tLayer = require("app.scenes.crosspvp.CrossPVPBetSelectLayer").create(selType, callback)
	if tLayer then
		uf_sceneManager:getCurScene():addChild(tLayer)
	end
end

function CrossPVPDoBetLayer:_updateBetAwardPage()
	self:_adaptScrollView()

	for i=1, 6 do
		self:_updateAward(CrossPVPConst.BET_FLOWER, i)
	end
	self:callAfterFrameCount(1, function()
		for i=1, 6 do
			self:_updateAward(CrossPVPConst.BET_EGG, i)
		end
	end)
end

function CrossPVPDoBetLayer:_adaptScrollView( ... )
	local nHeight = 0
	local nWidth = 0
	local panelEgg = self:getPanelByName("Panel_Egg_Award")
	nHeight = panelEgg:getSize().height

	local panelFlower = self:getPanelByName("Panel_Flower_Award")
	nHeight = nHeight + panelFlower:getSize().height

	local panelRule = self:getPanelByName("Panel_Rule")
	nHeight = nHeight + panelRule:getSize().height

	local tScrollView = self:getScrollViewByName("ScrollView_Award")
	nWidth = tScrollView:getSize().width
	tScrollView:setInnerContainerSize(CCSizeMake(nWidth, nHeight))

	panelEgg:setPositionY(0)
	panelFlower:setPositionY(panelEgg:getSize().height)
	panelRule:setPositionY(panelEgg:getSize().height + panelFlower:getSize().height)
end


function CrossPVPDoBetLayer:_initAwardScrollView(tScrollView, listData)
    tScrollView:removeAllChildren()
    local space = -15 --间隙
    local size = tScrollView:getContentSize()
    local _knightItemWidth = 0
    for i,v in ipairs(listData) do
        
        local btnName = "gift_item" .. "_" .. i
        local widget = require("app.scenes.giftmail.GiftMailIconCell").new(v,btnName)
        widget:setScale(0.8)
        widget:updateData(listData[i])
        _knightItemWidth = widget:getWidth()

        widget:setPositionXY(20 + _knightItemWidth*(i-1)+i*space, -4)
        tScrollView:addChild(widget)
    end
    local _scrollViewWidth = _knightItemWidth*#listData+space*(#listData+1)
    tScrollView:setInnerContainerSize(CCSizeMake(_scrollViewWidth + 20,size.height))
end

function CrossPVPDoBetLayer:_updateAward(nType, nIndex)
	local szLabelName = ""
	local szScrollViewName = ""
	local szBetType = ""
	local tTmplList = {}
	if nType == CrossPVPConst.BET_FLOWER then
		szLabelName = "Label_Flower_"..nIndex
		szScrollViewName = "ScrollView_Flower_"..nIndex
		szBetType = "LANG_CROSS_PVP_BET_FLOWER"
	elseif nType == CrossPVPConst.BET_EGG then
		szLabelName = "Label_Egg_"..nIndex
		szScrollViewName = "ScrollView_Egg_"..nIndex
		szBetType = "LANG_CROSS_PVP_BET_EGG"
	end

	local labelTitle = self:getLabelByName(szLabelName)
	local tScrollView = self:getScrollViewByName(szScrollViewName)
	if not labelTitle or not tScrollView then
		return
	end 

	for i=1, crosspvp_flower_award_info.getLength() do
		local tTmpl = crosspvp_flower_award_info.indexOf(i)
		if tTmpl and tTmpl.type == nType then
			table.insert(tTmplList, #tTmplList + 1, tTmpl)
		end
	end

	local tAwardList = {}
	local tTmpl = tTmplList[nIndex]
	if tTmpl then
		for j=1, 4 do
			local nType_ = tTmpl["award_type_"..j] or 0
			local nValue_ = tTmpl["award_value_"..j] or 0
			local nSize_ = tTmpl["award_size_"..j] or 0
			if nType_ ~= 0 then
				table.insert(tAwardList, #tAwardList + 1, {type=nType_, value=nValue_, size=nSize_})
			end 
		end
		if tTmpl.max_size > 300 then
			tTmpl.max_size = G_lang:get("LANG_CROSS_PVP_AWARD_UP", {num=tTmpl.min_size})
		end
		labelTitle:setText(G_lang:get(szBetType).."\n"..tTmpl.min_size.."~"..tTmpl.max_size)
		self:_initAwardScrollView(tScrollView, tAwardList)
	end
end

return CrossPVPDoBetLayer