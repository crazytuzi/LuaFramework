local TimePrivilegeWarningLayer = class("TimePrivilegeWarningLayer", UFCCSModelLayer)

function TimePrivilegeWarningLayer.create(szContent, yesCallback, noCallback, ...)
	return TimePrivilegeWarningLayer.new("ui_layout/timeprivilege_WarningLayer.json", Colors.modelColor, szContent, yesCallback, noCallback, ...)
end

function TimePrivilegeWarningLayer:ctor(json, param, szContent, yesCallback, noCallback, ...)
	self.super.ctor(self, json, param, ...)

    self._szContent = szContent or ""
	self._yesCallback = yesCallback
	self._noCallback = noCallback

	self:_initWidgets()
end

function TimePrivilegeWarningLayer:onLayerEnter()
	self:showAtCenter(true)

	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("ImageView_back"), "smoving_bounce")
end

function TimePrivilegeWarningLayer:onLayerExit()
	
end


function TimePrivilegeWarningLayer:_initWidgets()
    local labelContent = self:getLabelByName("Label_content")
    if labelContent then
        labelContent:setText(self._szContent)
        labelContent:createStroke(Colors.strokeBrown, 1)
    end

	self:showWidgetByName("Button_ok", false)
	self:registerBtnClickEvent("Button_yes", function(sender)
		if self._yesCallback then
            self._yesCallback()
            self:animationToClose()
		end
	end)

	self:registerBtnClickEvent("Button_no", function(sender)
		if self._noCallback then
            self._noCallback()
            self:animationToClose()
		end
	end)
end

return TimePrivilegeWarningLayer