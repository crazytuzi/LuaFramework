local CrossPVPReviewItem = class("CrossPVPReviewItem", UFCCSNormalLayer)

require("app.cfg.knight_info")
local CrossPVPConst = require("app.const.CrossPVPConst")
local CrossPVPCommon = require("app.scenes.crosspvp.CrossPVPCommon")

function CrossPVPReviewItem.create(battlefield)
	return CrossPVPReviewItem.new("ui_layout/crosspvp_ReviewItem.json", nil, battlefield)
end

function CrossPVPReviewItem:ctor(jsonFile, fun, battlefield)
	self._battlefield 	= battlefield 	-- 赛区
	self._curStage    	= 0				-- 该赛区当前所处的阶段
	self._labelChampion = self:getLabelByName("Label_Champion") 
	self.super.ctor(self, jsonFile, fun)
end

function CrossPVPReviewItem:onLayerLoad()
	self:_initContent()
end

function CrossPVPReviewItem:onLayerEnter()
	self:_updateState()
	uf_eventManager:addEventListener(CrossPVPConst.EVENT_STAGE_CHANGED, self._updateState, self)
end

function CrossPVPReviewItem:onLayerExit()
	self:_removeTimer()
end

function CrossPVPReviewItem:_createTimer()
	if not self._timer then
		self._timer = G_GlobalFunc.addTimer(1, handler(self, self._updateTime))
	end
end

function CrossPVPReviewItem:_removeTimer()
	if self._timer then
		G_GlobalFunc.removeTimer(self._timer)
		self._timer = nil
	end
end

function CrossPVPReviewItem:_initContent()
	-- flag image
	local flagImg = CrossPVPConst.FLAG_IMG[self._battlefield]
	self:getImageViewByName("Image_Flag"):loadTexture(flagImg)

	-- battlefield title
	local fieldName = CrossPVPConst.FIELD_NAME[self._battlefield]
	self:getImageViewByName("Image_Battlefield"):loadTexture(G_Path.getTextPath(fieldName))

	-- create stroke
	self:enableLabelStroke("Label_Begin", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_BeginTime", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_FieldState", Colors.strokeBrown, 1)
end

-- set text to the champion label, with color and stroke
function CrossPVPReviewItem:_setChampionText(text, color, enableStroke)
	self._labelChampion:setText(text)
	self._labelChampion:setColor(color)
	if enableStroke then
		self._labelChampion:createStroke(Colors.strokeBrown, 1)
	else
		self._labelChampion:removeStroke()
	end
end

function CrossPVPReviewItem:_waitChampion()
	-- get the accurate fight-end time of this battlefield
	local endTime
	if self._curStage == CrossPVPConst.STAGE_REVIEW then
		local lastCourse = G_Me.crossPVPData:getCourse() - 1
		endTime = select(2, G_Me.crossPVPData:getCourseTime(lastCourse))
	else
		endTime = G_Me.crossPVPData:getFieldBattleEndTime(self._battlefield)
	end
	local curTime = G_ServerTime:getTime()

	-- if the fight has already finished over 3 seconds, request the champion directly
	-- or, wait until 3 seconds after finishing
	local passedTime = curTime - endTime
	if passedTime >= CrossPVPConst.REQUEST_DELAY then
		self:_requestChampion()
	else
		self:_setChampionText(G_lang:get("LANG_CROSS_PVP_CALCULATING"), Colors.lightColors.DESCRIPTION, false)

		-- champion requesting delayed
		local delay = CrossPVPConst.REQUEST_DELAY - passedTime
		uf_funcCallHelper:callAfterDelayTime(delay, nil, function() self:_requestChampion()	end, nil)
	end
end

function CrossPVPReviewItem:_requestChampion()
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_PVP_GET_LAST_RANK, self._onRcvChampion, self)
	G_HandlersManager.crossPVPHandler:sendGetLastRank(self._battlefield, 0, 1)
end

function CrossPVPReviewItem:_onRcvChampion(data)
	if data and data.stage == self._battlefield and #data.ranks > 0 then
		local user = data.ranks[1]
		local knightInfo = knight_info.get(user.main_role)
		local color = Colors.qualityColors[knightInfo.quality]

		self:_setChampionText(user.name, color, true)
	else
		self:_setChampionText(G_lang:get("LANG_ROB_RICE_WAIT_RANK"), Colors.lightColors.DESCRIPTION, false)
	end

	if data and data.stage == self._battlefield then
		uf_eventManager:removeListenerWithEvent(self, G_EVENTMSGID.EVENT_CROSS_PVP_GET_LAST_RANK)
	end
end

function CrossPVPReviewItem:_updateState()
	if not self._battlefield then return end

	local course = G_Me.crossPVPData:getCourse()
	local stage = G_Me.crossPVPData:getFieldStage(self._battlefield)

	if stage ~= self._curStage then
		self._curStage = stage

		self:showWidgetByName("Panel_LeftTime", stage == CrossPVPConst.STAGE_REVIEW and
												course ~= CrossPVPConst.COURSE_EXTRA)
		self:showWidgetByName("Label_FieldState", stage ~= CrossPVPConst.STAGE_REVIEW and
												  stage ~= CrossPVPConst.STAGE_END)

		-- reset the champion label
		self:_setChampionText("", Colors.lightColors.DESCRIPTION, false)

		if stage == CrossPVPConst.STAGE_REVIEW then
			if course == CrossPVPConst.COURSE_PROMOTE_1024 then
				self._labelChampion:setText(G_lang:get("LANG_ROB_RICE_WAIT_RANK"))
				self:_updateTime()
			else
				self:_waitChampion()
			end
		elseif stage == CrossPVPConst.STAGE_BET or stage == CrossPVPConst.STAGE_ENCOURAGE then
			self._labelChampion:setText(G_lang:get("LANG_ROB_RICE_WAIT_RANK"))
			self:showTextWithLabel("Label_FieldState", G_lang:get("LANG_CROSS_PVP_BATTLE_BEGIN_SOON"))
		elseif stage == CrossPVPConst.STAGE_FIGHT then
			self._labelChampion:setText(G_lang:get("LANG_CROSS_PVP_IN_CONTEST"))
			self:showTextWithLabel("Label_FieldState", G_lang:get("LANG_CROSS_PVP_FIGHTING"))
		else
			self:_waitChampion()
		end

		-- deal with timer
		if stage == CrossPVPConst.STAGE_REVIEW and course ~= CrossPVPConst.COURSE_EXTRA then
			local hasBetStage = G_Me.crossPVPData:hasBetStage()
			self:showTextWithLabel("Label_Begin", G_lang:get(hasBetStage and "LANG_CROSS_PVP_BET_BEGIN_2"
																	  	  or "LANG_CROSS_PVP_BATTLE_BEGIN"))
			self:_createTimer()
			self:_updateTime()
		else
			self:_removeTimer()
		end
	end
end

function CrossPVPReviewItem:_updateTime()
	local battleBeginTime = G_Me.crossPVPData:getFieldBattleBeginTime(self._battlefield)
	local leftTime = CrossPVPCommon.getFormatLeftTime(battleBeginTime)
	self:showTextWithLabel("Label_BeginTime", leftTime)
	G_GlobalFunc.centerContent(self:getPanelByName("Panel_LeftTime"))
end

return CrossPVPReviewItem