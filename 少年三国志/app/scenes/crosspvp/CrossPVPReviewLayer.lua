local CrossPVPReviewLayer = class("CrossPVPReviewLayer", UFCCSNormalLayer)

require("app.cfg.crosspvp_schedule_info")
local CrossPVPConst 	 	= require("app.const.CrossPVPConst")
local CrossPVPCommon		= require("app.scenes.crosspvp.CrossPVPCommon")
local CrossPVPCourseFlow 	= require("app.scenes.crosspvp.CrossPVPCourseFlow")
local CrossPVPTurnFlagLayer	= require("app.scenes.crosspvp.CrossPVPTurnFlagLayer")

-- the distance between the middle panel border and the layer border
local PANEL_TO_TOP		= 335
local PANEL_TO_BOTTOM	= 130

function CrossPVPReviewLayer.create()
	return CrossPVPReviewLayer.new("ui_layout/crosspvp_ReviewLayer.json", nil)
end

function CrossPVPReviewLayer:ctor(jsonFile, fun)
	self.super.ctor(self, jsonFile, fun)
end

function CrossPVPReviewLayer:onLayerLoad()
	-- create stroke
	self:enableLabelStroke("Label_Title", Colors.strokeBrown, 2)

	-- attach match course layer
	self._courseLayer = CrossPVPCourseFlow.create()
	self:getRootWidget():addNode(self._courseLayer)

	-- add apply items
	local panel = self:getPanelByName("Panel_ScrollArea")
	CrossPVPTurnFlagLayer.create(panel, require("app.scenes.crosspvp.CrossPVPReviewItem"))
end

function CrossPVPReviewLayer:onLayerEnter()
	self:_adjustPanelPos()
	self:_updateTitle()
	uf_eventManager:addEventListener(CrossPVPConst.EVENT_STAGE_CHANGED, self._updateTitle, self)
end

function CrossPVPReviewLayer:onLayerExit(...)
	uf_eventManager:removeListenerWithTarget(self)
end

-- adjust the position of the middle panel
function CrossPVPReviewLayer:_adjustPanelPos()
	local panel = self:getPanelByName("Panel_Middle")
	local panelHeight = panel:getContentSize().height
	local layerHeight = self:getContentSize().height

	-- put the panel at the vacant area properly
	local vacantHeight = layerHeight - PANEL_TO_TOP - PANEL_TO_BOTTOM
	local y = PANEL_TO_BOTTOM + math.max(0, (vacantHeight - panelHeight) / 2)
	panel:setPositionY(y)
end

function CrossPVPReviewLayer:_updateTitle()
	local course 	= G_Me.crossPVPData:getCourse()
	local stage  	= G_Me.crossPVPData:getStage()
	local strTitle 	= ""

	if G_Me.crossPVPData:isCourseBegin(course) then
		local curCourseName = CrossPVPCommon.getCourseDesc(course)
		strTitle = G_lang:get("LANG_CROSS_PVP_COURSE_RUNNING", {cour = curCourseName})
	else
		local lastCourseName = CrossPVPCommon.getCourseDesc(course - 1)
		strTitle = G_lang:get("LANG_CROSS_PVP_COURSE_END", {cour = lastCourseName})
	end

	self:showTextWithLabel("Label_Title", strTitle)
end

return CrossPVPReviewLayer