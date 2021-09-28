require("app.cfg.bullet_screen_config")
local CrossPVPConst = require("app.const.CrossPVPConst")


local CrossPVPPreinstallInfoLayer = class("CrossPVPPreinstallInfoLayer", UFCCSModelLayer)


local PREINSTALL_MAX = 4


function CrossPVPPreinstallInfoLayer.create(callback, ...)
	local tLayer = CrossPVPPreinstallInfoLayer.new("ui_layout/crosspvp_PreinstallInfoLayer.json", Colors.modelColor, callback, ...)
	uf_sceneManager:getCurScene():addChild(tLayer)
	return tLayer
end

function CrossPVPPreinstallInfoLayer:ctor(json, param, callback, ...)
	self._nCheckedIndex = 0
	self._funcCallback = callback

	self.super.ctor(self, json, param, ...)
end

function CrossPVPPreinstallInfoLayer:onLayerLoad()
	self:_initWidgets()
	self:_initTabs()
	self:_initPreinstallInfo()
end

function CrossPVPPreinstallInfoLayer:onLayerEnter()
	self:showAtCenter(true)

	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("ImageView_Bg"), "smoving_bounce")

	uf_eventManager:addEventListener(CrossPVPConst.EVENT_STAGE_CHANGED, self._onCloseSelf, self)
	local nSelectedIndex = G_Me.crossPVPData:getSelectedPreInstall()
	for i=1, PREINSTALL_MAX do
		if nSelectedIndex == i then
			self:showWidgetByName("Image_Selected"..i, true)
		else
			self:showWidgetByName("Image_Selected"..i, false)
		end
	end

	--	self._tabs:checked("CheckBox_" .. nSelectedIndex)
end

function CrossPVPPreinstallInfoLayer:onLayerExit()
	
end

function CrossPVPPreinstallInfoLayer:onLayerUnload()
	
end

function CrossPVPPreinstallInfoLayer:_initWidgets()
	self:registerBtnClickEvent("Button_Close", handler(self, self._onCloseWindow))

	for i=1, PREINSTALL_MAX do
		local img = self:getImageViewByName(string.format("Image_Content%d", i))
		if img then
			img:setTag(i)
		end
		self:registerWidgetClickEvent(string.format("Image_Content%d", i), handler(self, self._onChoosedText))
	end
end

function CrossPVPPreinstallInfoLayer:_initPreinstallInfo()
	for i=1, PREINSTALL_MAX do
		local tTmpl = bullet_screen_config.get(i)
		local label = self:getLabelByName(string.format("Label_Content%d", i))
		if tTmpl and label then
			local szContent = G_Me.userData.name .. "：" .. tTmpl.comment
			label:setText(szContent)
		end
	end
end

function CrossPVPPreinstallInfoLayer:_initTabs()
	self._tabs = require("app.common.tools.Tabs").new(1, self, self._onTabChecked, self._onTabUnchecked)
	for i = 1, PREINSTALL_MAX do
		self._tabs:add("CheckBox_" .. i, nil, nil)
	end
end

function CrossPVPPreinstallInfoLayer:_onTabChecked(szCheckBoxName)
	for i=1, PREINSTALL_MAX do
		if szCheckBoxName == string.format("CheckBox_%d", i) then
			self._nCheckedIndex = i
			G_Me.crossPVPData:setSelectedPreInstall(self._nCheckedIndex)
			self:_showWithSelectedState()
			self:_onCloseWindow()
			break
		end
	end
end

function CrossPVPPreinstallInfoLayer:_onTabUnchecked()
	
end

function CrossPVPPreinstallInfoLayer:_onChoosedText(sender)
	local nTag = sender:getTag()
	self._nCheckedIndex = nTag
	G_Me.crossPVPData:setSelectedPreInstall(self._nCheckedIndex)
	self:_showWithSelectedState()
	self:_onCloseWindow()
end

function CrossPVPPreinstallInfoLayer:_onCloseWindow()
	self:_handlerChoosedEvent()
	self:animationToClose()
end

function CrossPVPPreinstallInfoLayer:_handlerChoosedEvent()
	if self._funcCallback then
		local tTmpl = bullet_screen_config.get(self._nCheckedIndex)
		if tTmpl then
			local szContent = G_Me.userData.name .. "：" .. tTmpl.comment
			self._funcCallback(szContent)
		end
	end
end

function CrossPVPPreinstallInfoLayer:_onCloseSelf()
	self:close()
end

function CrossPVPPreinstallInfoLayer:_showWithSelectedState()
	local nSelectedIndex = G_Me.crossPVPData:getSelectedPreInstall()
	for i=1, PREINSTALL_MAX do
		if nSelectedIndex == i then
			self:showWidgetByName("Image_Selected"..i, true)
		else
			self:showWidgetByName("Image_Selected"..i, false)
		end
	end
end

return CrossPVPPreinstallInfoLayer