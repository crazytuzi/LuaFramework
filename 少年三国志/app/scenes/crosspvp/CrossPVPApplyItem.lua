local CrossPVPApplyItem = class("CrossPVPApplyItem", UFCCSNormalLayer)

require("app.cfg.crosspvp_ground_info")
local CrossPVPConst = require("app.const.CrossPVPConst")
local CrossPVPCommon = require("app.scenes.crosspvp.CrossPVPCommon")

function CrossPVPApplyItem.create(battlefield)
	return CrossPVPApplyItem.new("ui_layout/crosspvp_ApplyItem.json", nil, battlefield)
end

--@param battleField: the type of the battlefield
function CrossPVPApplyItem:ctor(jsonFile, fun, battlefield)
	self._battlefield = battlefield
	self._isActive = false
	self._applyFinished = false
	self._canShowHint = false
	self._canShowCD = false
	self._timePanel = self:getPanelByName("Panel_LeftTime")
	self._hintLabel = self:getLabelByName("Label_ArenaRestrict")
	self.super.ctor(self, jsonFile, fun)
end

function CrossPVPApplyItem:onLayerLoad()
	self:_initContent()
	self:registerBtnClickEvent("Button_Apply", handler(self, self._onClickApply))
end

function CrossPVPApplyItem:onLayerEnter()
	self:_updateContent()
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_PVP_GET_FIELD_INFO, self._updateAttender, self)
end

function CrossPVPApplyItem:onLayerExit()
	self:_removeTimer()
	uf_eventManager:removeListenerWithTarget(self)
end

function CrossPVPApplyItem:onActive()
	self._isActive = true
	self:getButtonByName("Button_Apply"):setTouchEnabled(true)
	self._timePanel:setVisible(self._canShowCD)
	self._hintLabel:setVisible(self._canShowHint)
end

function CrossPVPApplyItem:onDeactive()
	self._isActive = false
	self:getButtonByName("Button_Apply"):setTouchEnabled(false)
	self._timePanel:setVisible(false)
	self._hintLabel:setVisible(false)
end

-- create a timer to update the countdown to battle
function CrossPVPApplyItem:_createTimer()
	if not self._timer then
		self._timer = G_GlobalFunc.addTimer(1, handler(self, self._updateTime))
	end
end

-- destroy the timer
function CrossPVPApplyItem:_removeTimer()
	if self._timer then
		G_GlobalFunc.removeTimer(self._timer)
		self._timer = nil
	end
end

-- initialize ui content by different battlefield type
function CrossPVPApplyItem:_initContent()
	-- flag image
	local flagImg = CrossPVPConst.FLAG_IMG[self._battlefield]
	self:getImageViewByName("Image_Flag"):loadTexture(flagImg)

	-- battlefield title
	local fieldName = CrossPVPConst.FIELD_NAME[self._battlefield]
	self:getImageViewByName("Image_BattleField"):loadTexture(G_Path.getTextPath(fieldName))

	-- level limitation
	local minLevel, maxLevel = G_Me.crossPVPData:getApplyLevelLimit(self._battlefield)
	local strlimit = G_lang:get("LANG_CROSS_PVP_APPLY_LEVEL_LIMIT", {min = minLevel, max = maxLevel})
	self:showTextWithLabel("Label_ApplyLevel", strlimit)

	-- create stroke
	self:enableLabelStroke("Label_ToFight", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_LeftTime", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_ArenaRestrict", Colors.strokeBrown, 1)
	self:showTextWithLabel("Label_ToFight", G_lang:get("LANG_CROSS_PVP_BATTLE_BEGIN"))
end

-- update ui content by different battlefield state
function CrossPVPApplyItem:_updateContent()
	local pvpData 		= G_Me.crossPVPData

	-- attender number
	self:_updateAttender()

	-- get current states
	local isApplied 	= pvpData:isApplied()
	local myField		= pvpData:getBattlefield()
	local curCourse 	= pvpData:getCourse()
	local isLevelSatisfy= pvpData:isLevelSatisfy(self._battlefield)
	local curNum, maxNum= pvpData:getApplyNum(self._battlefield)
	local isFull		= curNum >= maxNum

	-- show button or state tag
	local showApplyBtn 	= curCourse == CrossPVPConst.COURSE_APPLY and (not isApplied) and isLevelSatisfy and (not isFull)
	self:showWidgetByName("Button_Apply", showApplyBtn)
	self:showWidgetByName("Image_ApplyState", not showApplyBtn)

	-- set apply state
	if not showApplyBtn then
		local stageImg = (isApplied and myField == self._battlefield) and "yibaoming.png" or
							(curCourse > CrossPVPConst.COURSE_APPLY and "jt_baomingjieshu.png" or
								(isFull and "renshuyiman.png" or "dengjibufu.png"))
		self:getImageViewByName("Image_ApplyState"):loadTexture(G_Path.getTextPath(stageImg))
	end
	
	-- set color again
	local c = self:getRootWidget():getColor()
	self:getRootWidget():setColor(c)
end

-- update attender number
function CrossPVPApplyItem:_updateAttender()
	local curNum, maxNum = G_Me.crossPVPData:getApplyNum(self._battlefield)
	curNum = math.min(curNum, maxNum)
	local strNum = G_lang:get("LANG_CROSS_PVP_APPLY_NUM", {cur = curNum, max = maxNum})
	self:showTextWithLabel("Label_ApplyNum", strNum)
end

-- update the countdown to battle beginning
function CrossPVPApplyItem:_updateTime()
	local battleBeginTime = G_Me.crossPVPData:getFieldBattleBeginTime(self._battlefield)
	local leftTime = CrossPVPCommon.getFormatLeftTime(battleBeginTime)
	if leftTime then
		self:showTextWithLabel("Label_LeftTime", leftTime)
		G_GlobalFunc.centerContent(self._timePanel)
	else
		self._canShowCD = false
		self._timePanel:setVisible(false)
		self:_removeTimer()
	end
end

function CrossPVPApplyItem:_onClickApply()
	-- if the attender count has reached to max, or user's arena rank doesn't meet the demand,
	-- then he can't apply
	local curNum, maxNum = G_Me.crossPVPData:getApplyNum(self._battlefield)
	if curNum >= maxNum then
		G_MovingTip:showMovingTip(G_lang:get("LANG_CROSS_PVP_APPLY_FULL"))
	else
		uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_PVP_APPLY, self._updateContent, self)
		G_HandlersManager.crossPVPHandler:sendApply(self._battlefield)
	end
end

-- show the arena rank restrict to apply this battlefield
function CrossPVPApplyItem:showArenaRestrict()
	self._canShowHint = true

	-- set hint about rank restriction
	local rankRestrict = crosspvp_ground_info.get(self._battlefield).arena_rank
	local hint = G_lang:get("LANG_CROSS_PVP_APPLY_RESTRICT", {num = rankRestrict})

	self._hintLabel:setVisible(self._isActive)
	self._hintLabel:setText(hint)

	-- hide countdown panel
	self._timePanel:setVisible(false)
end

-- show left time to battle
function CrossPVPApplyItem:showBattleCountdown()
	self._canShowCD = true
	self._canShowHint = false

	-- init time and create timer
	self._timePanel:setVisible(self._isActive)
	self:_updateTime()
	self:_createTimer()

	-- hide the rank restriction hint
	self._hintLabel:setVisible(false)
end

return CrossPVPApplyItem