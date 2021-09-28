local CrossPVPBetLayer = class("CrossPVPBetLayer", UFCCSNormalLayer)

require("app.cfg.knight_info")
local CrossPVPConst = require("app.const.CrossPVPConst")
local CrossPVPCommon = require("app.scenes.crosspvp.CrossPVPCommon")
local CrossPVPStageFlow = require("app.scenes.crosspvp.CrossPVPStageFlow")

-- the distance between the middle content image and the layer border
local PANEL_TO_TOP		= 400
local PANEL_TO_BOTTOM	= 40
local INFO_TO_TOP 		= 250

function CrossPVPBetLayer.create()
	return CrossPVPBetLayer.new("ui_layout/crosspvp_BetLayer.json", nil)
end

function CrossPVPBetLayer:ctor(jsonFile, fun)
	self.super.ctor(self, jsonFile, fun)
	G_GlobalFunc.savePack(self, scenePack)
end

function CrossPVPBetLayer:onLayerLoad()
	-- create strokes
	self:enableLabelStroke("Label_MyField", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_FieldName", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_CurScore", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_Score", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_MyRank", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_Rank", Colors.strokeBrown, 1)
	
	self:enableLabelStroke("Label_Explain", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_MySupport", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_MyBet", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_BetEnd", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_Time", Colors.strokeBrown, 1)

	self:showTextWithLabel("Label_BetEnd", G_lang:get("LANG_CROSS_PVP_BET_END"))

	-- register button events
	self:registerBtnClickEvent("Button_FlowerRank", handler(self, self._onClickFlowerRank))
	self:registerBtnClickEvent("Button_Bet", handler(self, self._onClickBet))

	-- attach match stage layer
	self._stageLayer = CrossPVPStageFlow.create()
	self:getWidgetByName("Panel_Middle"):addNode(self._stageLayer)

	-- set base info
	self:_initFieldInfo()
end

function CrossPVPBetLayer:onLayerEnter()
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_PVP_GET_BET_INFO, self._onRcvBetInfo, self)

	self:_updateEndTime()
	self:_createTimer()

	-- request bet info
	G_HandlersManager.crossPVPHandler:sendGetBetInfo()
end

function CrossPVPBetLayer:onLayerExit()
	self:_removeTimer()
	uf_eventManager:removeListenerWithTarget(self)
end

function CrossPVPBetLayer:adapterLayer()
	local panel = self:getPanelByName("Panel_Middle")
	local panelWidth  = panel:getContentSize().width
	local panelHeight = panel:getContentSize().height
	local layerHeight = self:getContentSize().height

	-- adjust the position of the stage layer
	self._stageLayer:setPositionXY(panelWidth / 2, panelHeight)

	-- put the middle panel at the vacant area properly
	local vacantHeight = layerHeight - PANEL_TO_TOP - PANEL_TO_BOTTOM
	local y = PANEL_TO_BOTTOM + math.max(0, (vacantHeight - panelHeight) / 2)
	panel:setPositionY(y)

	-- set the position of the match info panel
	panel = self:getPanelByName("Panel_MatchInfo")
	panelHeight = panel:getContentSize().height
	y = layerHeight - panelHeight - INFO_TO_TOP
	panel:setPositionY(y)
end

function CrossPVPBetLayer:_createTimer()
	if not self._timer then
		self._timer = G_GlobalFunc.addTimer(1, handler(self, self._updateEndTime))
	end
end

function CrossPVPBetLayer:_removeTimer()
	if self._timer then
		G_GlobalFunc.removeTimer(self._timer)
		self._timer = nil
	end
end

-- initialize my battlefield info
function CrossPVPBetLayer:_initFieldInfo()
	local pvpData = G_Me.crossPVPData
	local isApplied = G_Me.crossPVPData:isApplied()
	local isEliminated = G_Me.crossPVPData:isEliminated()

	-- 设置战场名字
	if isApplied or isEliminated then
		local fieldName = CrossPVPCommon.getBattleFieldName(pvpData:getBattlefield())
		self:showTextWithLabel("Label_FieldName", fieldName)
	end

	-- 设置其他信息
	if isApplied then
		-- 参赛中，显示积分和排名
		local score = pvpData:getScore()
		self:showTextWithLabel("Label_Score", tostring(score))

		local rank = pvpData:getFieldRank()
		self:showTextWithLabel("Label_Rank", tostring(rank))
	elseif isEliminated then
		-- 被淘汰了，显示止步于哪一轮
		local course = pvpData:getCourse()
		local lastCourseName = CrossPVPCommon.getCourseDesc(course - 1)
		self:showTextWithLabel("Label_Score", G_lang:get("LANG_CROSS_PVP_STOP_IN_COURSE", {course = lastCourseName}))
		self:getLabelByName("Label_Score"):setPositionX(0)

		self:showWidgetByName("Label_CurScore", false)
		self:showWidgetByName("Label_MyRank", false)
		self:showWidgetByName("Label_Rank", false)
	else
		-- 既没有参赛也没有被淘汰，不显示任何信息
		self:showWidgetByName("Panel_MatchInfo", false)
	end
end

function CrossPVPBetLayer:_updateTargetName(betType)
	local label = self:getLabelByName(betType == CrossPVPConst.BET_FLOWER and "Label_FlowerTarget" or "Label_EggTarget")
	local target = nil
	if betType == CrossPVPConst.BET_FLOWER then
		target = G_Me.crossPVPData:getFlowerTarget()
	else
		target = G_Me.crossPVPData:getEggTarget()
	end

	if target then
		local knightInfo = knight_info.get(target.main_role)
		label:setText(target.name)
		label:setColor(Colors.qualityColors[knightInfo.quality])
		label:createStroke(Colors.strokeBrown, 1)
	else
		label:setText(G_lang:get("LANG_CROSS_PVP_NOT_BET_YET"))
	end
end

function CrossPVPBetLayer:_updateMyBuff()
	-- my flower and egg bet by others
	local getFlowerNum = G_Me.crossPVPData:getNumGetFlower()
	local getEggNum = G_Me.crossPVPData:getNumGetEgg()
	self:showTextWithLabel("Label_GetFlowerNum", tostring(getFlowerNum))
	self:showTextWithLabel("Label_GetEggNum", tostring(getEggNum))

	-- my buff addition
	local buffStr = CrossPVPCommon.getFlowerBuffAddition(getFlowerNum)
	local debuffStr = CrossPVPCommon.getEggBuffAddition(getEggNum)
	self:showTextWithLabel("Label_BuffNum", buffStr)
	self:showTextWithLabel("Label_DebuffNum", debuffStr)
end

function CrossPVPBetLayer:_updateEndTime()
	local _, betEndTime = G_Me.crossPVPData:getStageTime(CrossPVPConst.STAGE_BET)
	local leftTime = CrossPVPCommon.getFormatLeftTime(betEndTime)
	if leftTime == "" then
		self:showWidgetByName("Panel_CD", false)
		self:_removeTimer()
	else
		self:showTextWithLabel("Label_Time", leftTime)
		G_GlobalFunc.centerContent(self:getPanelByName("Panel_CD"))
	end
end

function CrossPVPBetLayer:_onRcvBetInfo()
	-- update my flower and egg bet by others and buff
	self:_updateMyBuff()

	-- my flower and egg betting to others
	local betFlowerNum = G_Me.crossPVPData:getNumBetFlower()
	local betEggNum = G_Me.crossPVPData:getNumBetEgg()
	self:showTextWithLabel("Label_BetFlowerNum", tostring(betFlowerNum))
	self:showTextWithLabel("Label_ThrowEggNum", tostring(betEggNum))

	-- bet flower target
	self:_updateTargetName(CrossPVPConst.BET_FLOWER)
	self:_updateTargetName(CrossPVPConst.BET_EGG)
end

function CrossPVPBetLayer:_onRcvBet(data)
	if data.type == CrossPVPConst.BET_FLOWER then
		self:showTextWithLabel("Label_BetFlowerNum", tostring(G_Me.crossPVPData:getNumBetFlower()))
	elseif data.type == CrossPVPConst.BET_EGG then
		self:showTextWithLabel("Label_ThrowEggNum", tostring(G_Me.crossPVPData:getNumBetEgg()))
	end

	self:_updateTargetName(data.type)

	-- if player bet himself, update his buff
	if tostring(data.role_id) == tostring(G_Me.userData.id) and
	   tostring(data.sid) == tostring(G_PlatformProxy:getLoginServer().id) then
	   self:_updateMyBuff()
	end
end

function CrossPVPBetLayer:_onClickFlowerRank()
	require("app.scenes.crosspvp.CrossPVPFlowerRankLayer").show(self)
end

function CrossPVPBetLayer:_onClickBet()
	local layer = require("app.scenes.crosspvp.CrossPVPDoBetLayer").create(self)
	uf_sceneManager:getCurScene():addChild(layer)
end

return CrossPVPBetLayer