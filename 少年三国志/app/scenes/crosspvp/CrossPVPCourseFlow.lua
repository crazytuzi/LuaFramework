local CrossPVPCourseFlow = class("CrossPVPCourseFlow", UFCCSNormalLayer)

local CrossPVPConst = require("app.const.CrossPVPConst")
local CrossPVPCommon = require("app.scenes.crosspvp.CrossPVPCommon")

local ICON_HIGHLIGHT	= "ui/crosspvp/icon_1.png"
local ICON_FOCUS	 	= "ui/crosspvp/icon_2.png"
local ICON_GRAY		 	= "ui/crosspvp/icon_3.png"

-- 这是26号字体相对24号字体的缩放度
-- 因为引擎底层禁止了在Label创建完之后再刷新字符串纹理，因此setFontSize()是没用的，所以只能用缩放来模拟
local FOCUS_FONT_ZOOM	= 1.077

function CrossPVPCourseFlow.create()
	return CrossPVPCourseFlow.new("ui_layout/crosspvp_CourseFlow.json", nil)
end

function CrossPVPCourseFlow:ctor(jsonFile, fun)
	self._course = 0
	self._nextCourse = 0
	self.super.ctor(self, jsonFile, fun)
end

function CrossPVPCourseFlow:onLayerLoad()
	-- create strokes
	for i = CrossPVPConst.COURSE_PROMOTE_1024, CrossPVPConst.COURSE_FINAL do
		self:enableLabelStroke("Label_Course_" .. i, Colors.strokeBrown, 1)
	end

	self:enableLabelStroke("Label_Info", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_InfoDetail", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_Begin", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_BeginTime", Colors.strokeBrown, 1)
end

function CrossPVPCourseFlow:onLayerEnter()
	self:_updateCourseState()
	uf_eventManager:addEventListener(CrossPVPConst.EVENT_STAGE_CHANGED, self._updateCourseState, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_PVP_APPLY, self._updateCourseState, self)
end

function CrossPVPCourseFlow:onLayerExit()
	self:_removeTimer()
	uf_eventManager:removeListenerWithTarget(self)
end

function CrossPVPCourseFlow:_createTimer()
	if not self._timer then
		self._timer = G_GlobalFunc.addTimer(1, handler(self, self._updateTime))
	end
end

function CrossPVPCourseFlow:_removeTimer()
	if self._timer then
		G_GlobalFunc.removeTimer(self._timer)
		self._timer = nil
	end
end

function CrossPVPCourseFlow:_updateCourseState()
	-- 首先，这个界面只有在报名阶段和战斗回顾阶段才出现
	-- 如果是在报名阶段，那么下一个赛程是海选
	-- 如果是在战斗回顾阶段，那么根据当前赛程是否已开始，来决定当前高亮的轮次和下一轮的轮次
	local course = G_Me.crossPVPData:getCourse()
	local nextCourse
	local isNotApplied  = (course == CrossPVPConst.COURSE_APPLY and not G_Me.crossPVPData:isApplied())
	local isJustApplied = (course == CrossPVPConst.COURSE_APPLY and G_Me.crossPVPData:isApplied())
	if isNotApplied or course == CrossPVPConst.COURSE_EXTRA then
		self:showWidgetByName("Panel_Info", false)
	elseif isJustApplied or G_Me.crossPVPData:isCourseBegin(course) then
		self:showWidgetByName("Panel_Info", true)
		nextCourse = course + 1
	else
		-- 这轮比赛还没开始，只是在回顾上轮比赛
		self:showWidgetByName("Panel_Info", true)
		nextCourse = course
		course = course - 1
	end

	-- highlight the passed courses, focus on the current course, set the remain courses as gray
	for i = CrossPVPConst.COURSE_PROMOTE_1024, CrossPVPConst.COURSE_FINAL do
		local icon = self:getImageViewByName("Image_Course_" .. i)
		local arrow = self:getImageViewByName("Image_Arrow_" .. i)
		local label = self:getLabelByName("Label_Course_" ..i)

		if i == course then
			icon:loadTexture(ICON_FOCUS)

			label:setColor(Colors.lightColors.TITLE_01)
			if i ~= CrossPVPConst.COURSE_FINAL then
				label:setScale(FOCUS_FONT_ZOOM)
			end

		elseif i < course then
			icon:loadTexture(ICON_HIGHLIGHT)
		else -- i > course
			icon:loadTexture(ICON_GRAY)

			if arrow then
				arrow:showAsGray(true)
			end
		end
	end

	self._course = course
	self._nextCourse = nextCourse

	-- set bottom text info
	if self:getWidgetByName("Panel_Info"):isVisible() then
		local infoLabel = self:getLabelByName("Label_Info")
		local detailLabel = self:getLabelByName("Label_InfoDetail")

		if isJustApplied then
			local fieldName = CrossPVPCommon.getBattleFieldName(G_Me.crossPVPData:getBattlefield())
			detailLabel:setText(fieldName)
			infoLabel:setText(G_lang:get("LANG_CROSS_PVP_APPLIED_COURSE"))

			detailLabel:setPositionX(infoLabel:getPositionX() + infoLabel:getContentSize().width)
		else
			local courseName = CrossPVPCommon.getCourseDesc(nextCourse)
			detailLabel:setText(courseName)
			infoLabel:setText(G_lang:get("LANG_CROSS_PVP_NEXT_COURSE"))
		end

		local hasBetStage = G_Me.crossPVPData:hasBetStageByCourse(nextCourse)
		self:showTextWithLabel("Label_Begin", G_lang:get(hasBetStage and "LANG_CROSS_PVP_BET_BEGIN_2"
																	  or "LANG_CROSS_PVP_BATTLE_BEGIN"))

		-- update countdown
		self:_updateTime()
		self:_createTimer()
	else
		self:_removeTimer()
	end
end

function CrossPVPCourseFlow:_updateTime()
	local battleBeginTime = 0
	if G_Me.crossPVPData:isApplying() and G_Me.crossPVPData:isApplied() then
		local myField = G_Me.crossPVPData:getBattlefield()
		battleBeginTime = G_Me.crossPVPData:getFieldBattleBeginTime(myField)
	else
		battleBeginTime = G_Me.crossPVPData:getCourseBattleBeginTime(self._nextCourse)
	end

	local leftTime = CrossPVPCommon.getFormatLeftTime(battleBeginTime)
	self:showTextWithLabel("Label_BeginTime", leftTime)
end

return CrossPVPCourseFlow