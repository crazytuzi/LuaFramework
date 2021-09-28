local CrossPVPApplyLayer = class("CrossPVPApplyLayer", UFCCSNormalLayer)

local CrossPVPConst 	 	= require("app.const.CrossPVPConst")
local CrossPVPCommon 		= require("app.scenes.crosspvp.CrossPVPCommon")
local CrossPVPCourseFlow 	= require("app.scenes.crosspvp.CrossPVPCourseFlow")
local CrossPVPTurnFlagLayer	= require("app.scenes.crosspvp.CrossPVPTurnFlagLayer")

function CrossPVPApplyLayer.create(scenePack, ...)
	return CrossPVPApplyLayer.new("ui_layout/crosspvp_ApplyLayer.json", nil, scenePack, ...)
end

function CrossPVPApplyLayer:ctor(jsonFile, fun, scenePack, ...)
	self._titleLabel = self:getLabelByName("Label_Title")

	self.super.ctor(self, jsonFile, fun, ...)
	G_GlobalFunc.savePack(self, scenePack)
end

function CrossPVPApplyLayer:onLayerLoad()
	-- create stroke
	self:enableLabelStroke("Label_Title", Colors.strokeBrown, 2)
	self:enableLabelStroke("Label_ApplyEnd", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_ApplyEndTime", Colors.strokeBrown, 1)
	self:showTextWithLabel("Label_ApplyEnd", G_lang:get("LANG_CROSS_PVP_APPLY_END_2"))

	-- attach match course layer
	self._courseLayer = CrossPVPCourseFlow.create()
	self:getRootWidget():addNode(self._courseLayer)

	-- add apply items
	local panel = self:getPanelByName("Panel_ScrollArea")
	self._turnFlagLayer = CrossPVPTurnFlagLayer.create(panel, require("app.scenes.crosspvp.CrossPVPApplyItem"))
end

function CrossPVPApplyLayer:onLayerEnter()
	-- jump to suitable flag
	self:_jumpToSuitableFlag()

	-- set apply state
	local isApplying = G_Me.crossPVPData:isApplying()
	self:showWidgetByName("Panel_ApplyTime", isApplying)
	
	if isApplying then
		self:_setApplyBegin()

		-- countdown
		self:_updateEndTime()
		self:_createTimer()
	else
		self:_setApplyEnd()
	end

	G_HandlersManager.crossPVPHandler:sendGetFieldInfo()
end

function CrossPVPApplyLayer:onLayerExit()
	self:_removeTimer()
end

function CrossPVPApplyLayer:onLayerUnload()

end

function CrossPVPApplyLayer:_createTimer()
	if not self._timer then
		self._timer = G_GlobalFunc.addTimer(1, handler(self, self._updateEndTime))
	end
end

function CrossPVPApplyLayer:_removeTimer()
	if self._timer then
		G_GlobalFunc.removeTimer(self._timer)
		self._timer = nil
	end
end

-- jump to a suitable flag item according to player's level and apply condition
function CrossPVPApplyLayer:_jumpToSuitableFlag()
	-- find a suitable battlefield for the player
	local myLevel   = G_Me.userData.level
	local suitField = 1

	if G_Me.crossPVPData:isApplied() then
		suitField = G_Me.crossPVPData:getBattlefield()
	else
		for i = CrossPVPConst.BATTLE_FIELD_NUM, 1, -1 do
			local minLevel, _ = G_Me.crossPVPData:getApplyLevelLimit(i)
			if myLevel >= minLevel then
				suitField = i
				break
			end
		end
	end

	-- jump to the flag of the suitable battlefield
	self._turnFlagLayer:_jumpToItem(suitField)
end

function CrossPVPApplyLayer:_setApplyBegin()
	self._titleLabel:setText(G_lang:get("LANG_CROSS_PVP_APPLY_BEGIN"))

	-- if is applying, show the arena rank restriction under each battlefield flag
	for i = 1, CrossPVPConst.BATTLE_FIELD_NUM do
		local item = self._turnFlagLayer:getItem(i)
		item:showArenaRestrict()
	end
end

function CrossPVPApplyLayer:_setApplyEnd()
	self._titleLabel:setText(G_lang:get("LANG_CROSS_PVP_APPLY_END"))

	-- if applying is end, show the countdown to battle under each battlefield flag
	for i = 1, CrossPVPConst.BATTLE_FIELD_NUM do
		local item = self._turnFlagLayer:getItem(i)
		item:showBattleCountdown()
	end
end

function CrossPVPApplyLayer:_updateEndTime()
	local _, endTime = G_Me.crossPVPData:getCourseTime(CrossPVPConst.COURSE_APPLY)
	local leftTime = CrossPVPCommon.getFormatLeftTime(endTime)
	if leftTime then
		self:showTextWithLabel("Label_ApplyEndTime", leftTime)
		G_GlobalFunc.centerContent(self:getPanelByName("Panel_ApplyTime"))
	else
		self:showWidgetByName("Panel_ApplyTime", false)
		self:_removeTimer()
		self:_setApplyEnd()
	end
end

return CrossPVPApplyLayer