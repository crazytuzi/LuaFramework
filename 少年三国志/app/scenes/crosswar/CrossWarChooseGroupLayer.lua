-- CrossWarChooseGroupLayer
-- This layer is used for the user to choose a group to join.

local CrossWarChooseGroupLayer = class("CrossWarChooseGroupLayer", UFCCSModelLayer)

require("app.cfg.contest_points_buff_info")
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
local CrossWarMessageBox = require("app.scenes.crosswar.CrossWarMessageBox")
local CrossWarCommon 	 = require("app.scenes.crosswar.CrossWarCommon")

function CrossWarChooseGroupLayer.create(...)
	return CrossWarChooseGroupLayer.new("ui_layout/crosswar_ChooseGroupLayer.json", 
		Colors.modelColor, ...)
end

function CrossWarChooseGroupLayer:ctor(...)
	self.super.ctor(self, ...)
end

function CrossWarChooseGroupLayer:onLayerLoad(...)
	-- initialize buff descriptions of 4 groups
	self:_initBuffDesc()

	-- register button events
	for i = 1, 4 do
		self:registerBtnClickEvent("Button_Group_" .. i, handler(self, self._onClickGroup))
	end

	EffectSingleMoving.run(self, "smoving_bounce")
	EffectSingleMoving.run(self:getWidgetByName("Image_Touch_To_Continue"), "smoving_wait", nil, {position = true})
end

function CrossWarChooseGroupLayer:onLayerEnter(...)
	self:showAtCenter(true)
	self:closeAtReturn(true)
	self:setClickClose(true)

	-- register event listners
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_SELECT_GROUP, self._onRcvSelectGroup, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_ENTER_SCORE_MATCH, self._onRcvEnterMatch, self)

	uf_eventManager:addEventListener(CrossWarCommon.EVENT_STATE_CHANGED, self._updateMatchState, self)
end

function CrossWarChooseGroupLayer:onLayerExit(...)
	uf_eventManager:removeListenerWithTarget(self)
end

-- initialize buff descriptions of 4 groups
function CrossWarChooseGroupLayer:_initBuffDesc()
	local groupNum = contest_points_buff_info.getLength()

	for i = 1, groupNum do
		local buff = contest_points_buff_info.get(i).buff
		self:showTextWithLabel("Label_Buff_" .. i, buff)
		self:enableLabelStroke("Label_Buff_" .. i, Colors.strokeBrown, 2)
	end
end

-- click handler of the group buttons
function CrossWarChooseGroupLayer:_onClickGroup(widget)
	local group = widget:getTag()

	CrossWarMessageBox.show(CrossWarMessageBox.JOIN_GROUP, group, function()
		G_HandlersManager.crossWarHandler:sendSelectGroup(group)
	end)
end

-- handler of the "EVENT_CROSS_WAR_SELECT_GROUP" event
function CrossWarChooseGroupLayer:_onRcvSelectGroup()
	G_MovingTip:showMovingTip(G_lang:get("LANG_CROSS_WAR_JOIN_GROUP_SUCCESS"))

	-- group selected, pull the score match base info
	G_HandlersManager.crossWarHandler:sendEnterScoreBattle()
end

-- handler of the "EVENT_CROSS_WAR_ENTER_SCORE_MATCH" event
function CrossWarChooseGroupLayer:_onRcvEnterMatch()
	-- enter the score match layer
	local layer = require("app.scenes.crosswar.CrossWarScoreMatchLayer").create()
	uf_sceneManager:getCurScene():replaceLayer(layer)

	-- close self
	self:animationToClose()
end

function CrossWarChooseGroupLayer:_updateMatchState()
	if not G_Me.crossWarData:isInScoreMatch() then
		self:animationToClose()
	end
end

return CrossWarChooseGroupLayer