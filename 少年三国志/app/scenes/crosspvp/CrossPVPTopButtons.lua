local CrossPVPTopButtons = class("CrossPVPTopButtons", UFCCSNormalLayer)

local CrossPVPConst = require("app.const.CrossPVPConst")

local BUTTON_TO_TOP   = 175
local BUTTON_INTERVAL = 100
local BUTTON_FIRST_X  = 580

function CrossPVPTopButtons.create()
	return CrossPVPTopButtons.new("ui_layout/crosspvp_TopButtons.json", nil)
end

function CrossPVPTopButtons:ctor(jsonFile, fun)
	self._btnScoreRank	= self:getButtonByName("Button_ScoreRank")
	self._btnBetRank   	= self:getButtonByName("Button_BetRank")
	self._btnMatchAward	= self:getButtonByName("Button_MatchAward")
	self._btnViewAward 	= self:getButtonByName("Button_ViewAward")
	self._btnBetAward 	= self:getButtonByName("Button_BetAward")

	self.super.ctor(self, jsonFile, fun)
end

function CrossPVPTopButtons:onLayerLoad()
	self:_initButtonY()

	-- register button click events
	self:registerBtnClickEvent("Button_ScoreRank", handler(self, self._onClickScoreRank))
	self:registerBtnClickEvent("Button_BetRank", handler(self, self._onClickBetRank))
	self:registerBtnClickEvent("Button_MatchAward", handler(self, self._onClickMatchAward))
	self:registerBtnClickEvent("Button_ViewAward", handler(self, self._onClickViewAward))
	self:registerBtnClickEvent("Button_BetAward", handler(self, self._onClickBetAward))
end

function CrossPVPTopButtons:onLayerEnter()
	self:_updateButtonStates()
	uf_eventManager:addEventListener(CrossPVPConst.EVENT_STAGE_CHANGED, self._updateButtonStates, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_PVP_GET_REVIEW_INFO, self._updateButtonStates, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_PVP_GET_BET_AWARD, self._updateButtonStates, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_PVP_GET_PROMOTED_AWARD_SUCC, self._updateButtonStates, self)
end

function CrossPVPTopButtons:onLayerExit()
	uf_eventManager:removeListenerWithTarget(self)
end

function CrossPVPTopButtons:_onClickScoreRank()
	require("app.scenes.crosspvp.CrossPVPScoreRankLayer").show()
end

function CrossPVPTopButtons:_onClickBetRank()
	require("app.scenes.crosspvp.CrossPVPBetRankLayer").show()
end

function CrossPVPTopButtons:_onClickMatchAward()
	require("app.scenes.crosspvp.CrossPVPDoGetPromotedAwardLayer").show()
end

function CrossPVPTopButtons:_onClickViewAward()
	local attachBtn = self:getWidgetByName("Button_ViewAward")
	local btnSize   = attachBtn:getContentSize()
	local btnX,btnY = attachBtn:getPosition()
	local attachPos = ccp(btnX - 8, btnY - btnSize.height / 2)

	require("app.scenes.crosspvp.CrossPVPTopButtonsSub").show(attachPos)
end

function CrossPVPTopButtons:_onClickBetAward()
	require("app.scenes.crosspvp.CrossPVPBetAwardLayer").show()
end

function CrossPVPTopButtons:_updateButtonStates()
	self:_updateScoreRankButton()
	self:_updateBetRankButton()
	self:_updateMatchAwardButton()
	self:_updateBetAwardButton()
	self:_alignToRight()
end

-- 更新积分排行榜按钮的显示
function CrossPVPTopButtons:_updateScoreRankButton()
	local pvpData = G_Me.crossPVPData
	local course = pvpData:getCourse()
	local stage  = pvpData:getStage()
	local hasBet = pvpData:hasBetStage()
	
	-- 投注阶段总是显示排行榜
	if hasBet and stage == CrossPVPConst.STAGE_BET then
		self._btnScoreRank:setVisible(true)
		return
	end

	if pvpData:isApplied() or pvpData:isEliminated() then
		-- 对于参赛的人，比赛结束后显示排行榜
		local myStage = pvpData:getFieldStage(pvpData:getBattlefield())
		if course == CrossPVPConst.COURSE_PROMOTE_1024 then
			self._btnScoreRank:setVisible(myStage == CrossPVPConst.STAGE_END)
		else
			self._btnScoreRank:setVisible(myStage == CrossPVPConst.STAGE_REVIEW)
		end
	else
		-- 对于未参赛的人，海选中初级战场结束后显示排行榜
		-- 其余轮次回顾阶段都显示排行榜
		if course == CrossPVPConst.COURSE_PROMOTE_1024 then
			local firstStage = pvpData:getFieldStage(1)
			self._btnScoreRank:setVisible(firstStage == CrossPVPConst.STAGE_END)
		else
			self._btnScoreRank:setVisible(stage == CrossPVPConst.STAGE_REVIEW)
		end
	end
end

-- 更新投注排行榜按钮的显示
function CrossPVPTopButtons:_updateBetRankButton()
	local pvpData = G_Me.crossPVPData
	local stage = pvpData:getStage()

	-- 如果上轮有投注，那么在本轮的回顾阶段会显示投注榜按钮
	-- 如果本轮有投注，那么在本轮的投注和鼓舞阶段，以及观战选择界面显示投注榜按钮
	--[[if pvpData:hasLastBetStage() and stage == CrossPVPConst.STAGE_REVIEW then
		self._btnBetRank:setVisible(true)
	else]]if pvpData:hasBetStage() and 
			(stage == CrossPVPConst.STAGE_BET or stage == CrossPVPConst.STAGE_ENCOURAGE or
			 (stage == CrossPVPConst.STAGE_FIGHT and not G_Me.crossPVPData:isApplied())) then
		self._btnBetRank:setVisible(true)
	else
		self._btnBetRank:setVisible(false)
	end
end

-- 更新比赛奖励按钮的显示
function CrossPVPTopButtons:_updateMatchAwardButton()
	local pvpData = G_Me.crossPVPData
	local course = pvpData:getCourse()
	local stage = pvpData:getStage()

	-- 比赛结束阶段，如果排名结算尚未完成，暂时先不显示奖励按钮
	if stage == CrossPVPConst.STAGE_REVIEW or stage == CrossPVPConst.STAGE_END then
		if pvpData:isWaitResult() then
			self._btnMatchAward:setVisible(false)
			self._btnViewAward:setVisible(false)
			return
		end
	end

	-- 上轮参赛的人，在比赛结束至下轮投注之间，并且还没领奖，可以看到比赛奖励按钮
	if (pvpData:isApplied() or pvpData:isEliminated()) and pvpData:hasMatchAward() then
		local myStage = pvpData:getFieldStage(pvpData:getBattlefield())
		local showAward = false
		if course == CrossPVPConst.COURSE_PROMOTE_1024 and myStage == CrossPVPConst.STAGE_END then
			self._btnMatchAward:setVisible(true)
			self._btnViewAward:setVisible(false)
			showAward = true
		elseif course > CrossPVPConst.COURSE_PROMOTE_1024 and (myStage == CrossPVPConst.STAGE_REVIEW or myStage == CrossPVPConst.STAGE_BET) then
			self._btnMatchAward:setVisible(true)
			self._btnViewAward:setVisible(false)
			showAward = true
		end

		if showAward then
			local btnText = G_Path.getTxt(pvpData:isApplied() and "jzcb-jinjijiangli.png" or "icon-canyujiangli.png")
			local btnImg  = pvpData:isApplied() and "ui/activity/icon_quanfujiangli1.png" or "ui/crosswar/icon_lianshengjiangli.png"
			self:getImageViewByName("Image_MatchAward"):loadTexture(btnText)
			self._btnMatchAward:loadTextureNormal(btnImg)
			return
		end
	end

	-- 只要奖励按钮没显示，那么就显示奖励预览
	self._btnMatchAward:setVisible(false)
	self._btnViewAward:setVisible(true)
end

-- 更新投注奖励按钮的显示
function CrossPVPTopButtons:_updateBetAwardButton()
	-- 回顾阶段和投注阶段，如果还有投注奖励没有领，就显示
	local stage = G_Me.crossPVPData:getStage()
	local hasBetAward = G_Me.crossPVPData:hasBetAward()
	self._btnBetAward:setVisible(hasBetAward and (stage == CrossPVPConst.STAGE_REVIEW or stage == CrossPVPConst.STAGE_BET))
end

function CrossPVPTopButtons:_initButtonY()
	local root = self:getRootWidget()
	local size = self:getContentSize()
	local children = {}

	if device.platform == "wp8" or device.platform == "winrt" then
        children = root:getChildrenWidget() or {}
    else
        children = root:getChildren() or {}
    end

    local count = children:count()
    for i = 0, count - 1 do
    	local obj = children:objectAtIndex(i)
    	obj:setPositionY(size.height - BUTTON_TO_TOP)
    end
end

function CrossPVPTopButtons:_alignToRight()
	local root = self:getRootWidget()
	local size = self:getContentSize()
	local children = {}

	if device.platform == "wp8" or device.platform == "winrt" then
        children = root:getChildrenWidget() or {}
    else
        children = root:getChildren() or {}
    end

    local posX = BUTTON_FIRST_X
    local count = children:count()
    for i = 0, count - 1 do
    	local obj = children:objectAtIndex(i)
    	if obj:isVisible() then
    		obj:setPositionX(posX)
    		posX = posX - BUTTON_INTERVAL
    	end
    end
end

return CrossPVPTopButtons