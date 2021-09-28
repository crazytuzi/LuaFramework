-- CrossWarInviteLayer
-- This layer represents the invitation received when you are qualified to the cross-war-championship match

local CrossWarInviteLayer = class("CrossWarInviteLayer", UFCCSModelLayer)

require("app.cfg.contest_points_buff_info")
local CrossWarCommon = require("app.scenes.crosswar.CrossWarCommon")
local KnightPic = require("app.scenes.common.KnightPic")
local EffectSingleMoving = require("app.common.effects.EffectSingleMoving")

function CrossWarInviteLayer.create(openFromMainscene, ...)
	return CrossWarInviteLayer.new("ui_layout/crosswar_Invitation.json", Colors.modelColor, openFromMainscene, ...)
end

function CrossWarInviteLayer:ctor(json, color, openFromMainscene, ...)
	self._openFromMainscene = openFromMainscene or false
	self.super.ctor(self, ...)
end

function CrossWarInviteLayer:onLayerLoad(...)
	-- hide the countdown label if necessary
	self:showWidgetByName("Panel_Countdown", not self._openFromMainscene and G_Me.crossWarData:getCurState() == CrossWarCommon.STATE_AFTER_SCORE_MATCH)

	-- create strokes
	self:enableLabelStroke("Label_Rank", Colors.strokeBrown, 2)
	self:enableLabelStroke("Label_UserName", Colors.strokeBrown, 2)

	-- initialize contents
	self:_initContents()

	-- 
	EffectSingleMoving.run(self, "smoving_bounce")
	EffectSingleMoving.run(self:getWidgetByName("Image_Touch_To_Continue"), "smoving_wait", nil, {position = true})

	-- TEST:
	--[[local knightIDs = { }
	for i = 10011, 10021 do
		knightIDs[#knightIDs + 1] = i
	end
	for i = 10024, 10026 do
		knightIDs[#knightIDs + 1] = i
	end
	for i = 10041, 10053 do
		knightIDs[#knightIDs + 1] = i
	end

	local index = 1
	local handler = function(widget, event)
		if event == TOUCH_EVENT_ENDED then
			local knightParent = self:getPanelByName("Panel_Knight")
			self._knightPic:removeFromParentAndCleanup(true)
			self._knightPic = KnightPic.createKnightPic(knightIDs[index], knightParent, "Knight_Pic", false)

			index = index + 1
			if index == #knightIDs then index = 1 end
		end
	end
	self:registerWidgetTouchEvent("Image_GroupIcon", handler)]]
end

function CrossWarInviteLayer:onLayerEnter(...)
	self:showAtCenter(true)
	self:closeAtReturn(true)
	self:setClickClose(true)

	-- register event listners
	uf_eventManager:addEventListener(CrossWarCommon.EVENT_STATE_CHANGED, self._updateMatchState, self)
	uf_eventManager:addEventListener(CrossWarCommon.EVENT_UPDATE_COUNTDOWN, self._updateCD, self)
end

function CrossWarInviteLayer:onLayerExit(...)
	uf_eventManager:removeListenerWithTarget(self)
end

function CrossWarInviteLayer:_initContents()
	local qualifyType = G_Me.crossWarData:getQualifyType()
	local qualifyRank = G_Me.crossWarData:getQualifyRank()
	local groupID 	  = G_Me.crossWarData:getGroup()

	self:showWidgetByName("Image_GroupIcon", qualifyType == 1)
	self:showWidgetByName("Label_Score", qualifyType == 1)
	self:showWidgetByName("Label_ScoreNum", qualifyType == 1)

	-- invitaion description text
	local templateLabel = self:getLabelByName("Label_InviteDesc")
	local parent = templateLabel:getParent()
	local content = ""
	if qualifyType == 1 then
		local groupName = contest_points_buff_info.get(groupID).name
		content = G_lang:get("LANG_CROSS_WAR_INVITE_1", {group = groupName, rank = qualifyRank})
	else
		local time = G_Me.crossWarData:getQualifyTime()
		local date = os.date("*t", time)
		content = G_lang:get("LANG_CROSS_WAR_INVITE_2", {m = date.month, d = date.day, rank = qualifyRank})
	end
	CrossWarCommon.createRichTextFromTemplate(templateLabel, parent, content, kCCTextAlignmentLeft)

	-- role picture and group icon
	local knightParent = self:getPanelByName("Panel_Knight")
	local resID = G_Me.dressData:getDressedPic()
	self._knightPic = KnightPic.createKnightPic(resID, knightParent, "Knight_Pic", false)

	if qualifyType == 1 then
		local iconTex = contest_points_buff_info.get(groupID).icon2
		self:getImageViewByName("Image_GroupIcon"):loadTexture(iconTex)
	end

	-- rank, player name, server name and score
	local myRank = qualifyRank
	local myName = G_Me.userData.name
	local server = G_PlatformProxy:getLoginServer().name
	local score  = G_Me.crossWarData:getScore()
	self:showTextWithLabel("Label_Rank", G_lang:get("LANG_ARENA_RANKING", {rank = myRank}))
	self:showTextWithLabel("Label_UserName", myName)
	self:showTextWithLabel("Label_ServerName", "(" .. string.gsub(server, "^.-%((.-)%)", "%1") .. ")")
	self:showTextWithLabel("Label_ScoreNum", tostring(score))
	self:showTextWithLabel("Label_Score", G_lang:get("LANG_JIFEN"))
end

function CrossWarInviteLayer:_updateMatchState()
	local needCD = G_Me.crossWarData:getCurState() == CrossWarCommon.STATE_AFTER_SCORE_MATCH
	if not needCD then
		self:animationToClose()
	end
end

-- update the countdown to championship-match
function CrossWarInviteLayer:_updateCD(strCD)
	local needCD = G_Me.crossWarData:getCurState() == CrossWarCommon.STATE_AFTER_SCORE_MATCH
	if needCD then
		self:showTextWithLabel("Label_CD_Time", strCD)

		-- adjust the whole line, keep it at the center
		local panel = self:getPanelByName("Panel_Countdown")
		CrossWarCommon.centerContent(panel)
	end
end

return CrossWarInviteLayer