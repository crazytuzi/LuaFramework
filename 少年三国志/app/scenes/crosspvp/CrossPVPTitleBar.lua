local CrossPVPConst = require("app.const.CrossPVPConst")
local CrossPVPCommon = require("app.scenes.crosspvp.CrossPVPCommon")

local CrossPVPTitleBar = class("CrossPVPTitleBar", UFCCSNormalLayer)

function CrossPVPTitleBar.create()
	return CrossPVPTitleBar.new("ui_layout/crosspvp_TitleBar.json", nil)
end

function CrossPVPTitleBar:ctor(jsonFile, fun)
	self._helpLayer = nil
	self.super.ctor(self, jsonFile, fun)
end

function CrossPVPTitleBar:onLayerLoad()
	self:registerBtnClickEvent("Button_Help", handler(self, self._onClickHelp))
	self:registerBtnClickEvent("Button_Back", handler(self, self._onClickBack))
end

function CrossPVPTitleBar:onLayerEnter()
	uf_eventManager:addEventListener(CrossPVPConst.EVENT_STAGE_CHANGED, self._onStageChanged, self)
end

function CrossPVPTitleBar:_onStageChanged()
	if self._helpLayer and self._helpLayer.animationToClose then
		self._helpLayer:animationToClose()
		self._helpLayer = nil
	end
end

function CrossPVPTitleBar:_onClickHelp()
	local curScene = uf_sceneManager:getCurScene()
	if curScene._mainBody and curScene._mainBody.layerName then
		if curScene._mainBody.layerName == "CrossPVPFightMainLayer" then
			self._helpLayer = require("app.scenes.common.CommonHelpLayer").show(
			{
				{title = G_lang:get("LANG_CROSS_PVP_HELP_TITLE3"), content = G_lang:get("LANG_CROSS_PVP_HELP_CONTENT3")},
			})
		else
			self._helpLayer = require("app.scenes.common.CommonHelpLayer").show(
			{
				{title = G_lang:get("LANG_CROSS_PVP_HELP_TITLE1"), content = G_lang:get("LANG_CROSS_PVP_HELP_CONTENT1")},
				{title = G_lang:get("LANG_CROSS_PVP_HELP_TITLE2"), content = G_lang:get("LANG_CROSS_PVP_HELP_CONTENT2")},
				{title = G_lang:get("LANG_CROSS_PVP_HELP_TITLE3"), content = G_lang:get("LANG_CROSS_PVP_HELP_CONTENT3")},
			})
		end
	else
		self._helpLayer = require("app.scenes.common.CommonHelpLayer").show(
		{
			{title = G_lang:get("LANG_CROSS_PVP_HELP_TITLE1"), content = G_lang:get("LANG_CROSS_PVP_HELP_CONTENT1")},
			{title = G_lang:get("LANG_CROSS_PVP_HELP_TITLE2"), content = G_lang:get("LANG_CROSS_PVP_HELP_CONTENT2")},
			{title = G_lang:get("LANG_CROSS_PVP_HELP_TITLE3"), content = G_lang:get("LANG_CROSS_PVP_HELP_CONTENT3")},
		})
	end
end

function CrossPVPTitleBar:_onClickBack()
	uf_sceneManager:getCurScene():onBackKeyEvent()
end

function CrossPVPTitleBar:updateTitle(inFightLayer)
	local imgTitle = self:getImageViewByName("Image_Title")
	if not imgTitle then
		return
	end
	if inFightLayer then
		local nCourse = G_Me.crossPVPData:getCourse()
		imgTitle:loadTexture(CrossPVPCommon.getCourseTitle(nCourse))
	else
		imgTitle:loadTexture(CrossPVPCommon.getDefaultTitle())
	end
end

return CrossPVPTitleBar