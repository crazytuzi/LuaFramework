local CrossPVPStageFlow = class("CrossPVPStageFlow", UFCCSNormalLayer)

local CrossPVPConst  = require("app.const.CrossPVPConst")
local CrossPVPCommon = require("app.scenes.crosspvp.CrossPVPCommon")

local SHORT_HIGHLIGHT = { "", 
						  "ui/legion/bg_baoming_dianliang.png",
						  "ui/legion/bg_pipei_dianliang.png",
						  "ui/legion/bg_kaizhan_dianliang.png"}

local LONG_HIGHLIGHT = { "",
                         "",
                         "ui/legion/bg_baoming_dianliang.png",
                         "ui/legion/bg_kaizhan_dianliang.png"}

function CrossPVPStageFlow.create()
	return CrossPVPStageFlow.new("ui_layout/crosspvp_StageFlow.json", nil)
end

function CrossPVPStageFlow:ctor(jsonFile, fun)
	self.super.ctor(self, jsonFile, fun)
end

function CrossPVPStageFlow:onLayerLoad()
	-- create stroke
	self:enableLabelStroke("Label_CourseTitle", Colors.strokeBrown, 2)

	-- initialize stage time
	self:_initStageTime()
end

function CrossPVPStageFlow:onLayerEnter()
	self:_updateStageState()
end

function CrossPVPStageFlow:_initStageTime()
	local hasBet = G_Me.crossPVPData:hasBetStage()
	local timeLabelPrefix = hasBet and "Label_TimeShort_" or "Label_TimeLong_"

	for i = 1, CrossPVPConst.STAGE_FIGHT do
		local label = self:getLabelByName(timeLabelPrefix .. i)
		if label then
			local start, close = G_Me.crossPVPData:getStageTime(i)
			local startDate = G_ServerTime:getDateObject(start)
			local closeDate = G_ServerTime:getDateObject(close)
			label:setText(string.format("%02d:%02d-%02d:%02d", startDate.hour, startDate.min, closeDate.hour, closeDate.min))
		end
	end
end

function CrossPVPStageFlow:_updateStageState()
	local course = G_Me.crossPVPData:getCourse()
	local stage = G_Me.crossPVPData:getStage()

	-- course name
	local courseName = CrossPVPCommon.getCourseDesc(course)
	self:showTextWithLabel("Label_CourseTitle", courseName)

	-- choose different panel
	local hasBet = G_Me.crossPVPData:hasBetStage()
	self:showWidgetByName("Panel_FlowWithBet", hasBet)
	self:showWidgetByName("Panel_FlowWithoutBet", not hasBet)

	-- set stage tag images
	if hasBet then
		self:_updateStageWithBet(stage)
	else
		self:_updateStageWithoutBet(stage)
	end
end

function CrossPVPStageFlow:_updateStageWithBet(stage)
	for i = CrossPVPConst.STAGE_BET, CrossPVPConst.STAGE_FIGHT do
		-- highlight passed and current stages
		if i <= stage then
			self:getImageViewByName("Image_FlowShort_" .. i):loadTexture(SHORT_HIGHLIGHT[i])

			local labelStage = self:getLabelByName("Label_StageShort_" .. i)
			local labelTime  = self:getLabelByName("Label_TimeShort_" .. i)
			self:_highlightLabel(labelStage, labelTime)
		end

		-- focus on current stage
		self:getImageViewByName("Image_LightShort_" .. i):setVisible(i == stage)
	end
end

function CrossPVPStageFlow:_updateStageWithoutBet(stage)
	for i = CrossPVPConst.STAGE_ENCOURAGE, CrossPVPConst.STAGE_FIGHT do
		if i <= stage then
			self:getImageViewByName("Image_FlowLong_" .. i):loadTexture(LONG_HIGHLIGHT[i])
			
			local labelStage = self:getLabelByName("Label_StageLong_" .. i)
			local labelTime  = self:getLabelByName("Label_TimeLong_" .. i)
			self:_highlightLabel(labelStage, labelTime)
		end

		self:getImageViewByName("Image_LightLong_" .. i):setVisible(i == stage)
	end
end

function CrossPVPStageFlow:_highlightLabel(labelStage, labelTime)
	labelStage:setColor(Colors.darkColors.DESCRIPTION)
	labelTime:setColor(Colors.darkColors.DESCRIPTION)
	labelStage:createStroke(Colors.strokeBrown, 1)
	labelTime:createStroke(Colors.strokeBrown, 1)
end

return CrossPVPStageFlow