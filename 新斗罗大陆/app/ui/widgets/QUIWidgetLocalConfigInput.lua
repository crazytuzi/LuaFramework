
-- 本地调试配置的输入

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetLocalConfigInput = class("QUIWidgetLocalConfigInput", QUIWidget)


QUIWidgetLocalConfigInput.INPUT_MOD_NUMBER = 1	-- 输入模式整数
QUIWidgetLocalConfigInput.INPUT_MOD_TEXT = 2	-- 输入模式文本


function QUIWidgetLocalConfigInput:ctor(options)
	local ccbFile = "ccb/Widget_local_config_input.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTouchBtn", callback = handler(self, self._onTouchBtn)},
	}
	QUIWidgetLocalConfigInput.super.ctor(self, ccbFile, callBacks, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end


function QUIWidgetLocalConfigInput:setInfo(config)
	self._configs = config

	self._ccbOwner.tf_name:setString(self._configs.showName)
	local width = self._ccbOwner.tf_name:getContentSize().width
	self._ccbOwner.node_offset:setPositionX(width + 5)

	self._ccbOwner.tf_value:setString(tostring(config.values))

	self._placeText = "请输入文本"
	self._inputMod = QUIWidgetLocalConfigInput.INPUT_MOD_TEXT
	if self._configs.values then
		if self._configs.values == QUIWidgetLocalConfigInput.INPUT_MOD_NUMBER then
			self._inputMod = QUIWidgetLocalConfigInput.INPUT_MOD_NUMBER
			self._placeText = "请输入数字"
		end
	end
end

function QUIWidgetLocalConfigInput:setValue(value)
	self._configs.values = value
	self._ccbOwner.tf_value:setString(tostring(value))
end

function QUIWidgetLocalConfigInput:getValue()
	local text = string.trim(self._ccbOwner.tf_value:getString())
	if self._inputMod == QUIWidgetLocalConfigInput.INPUT_MOD_NUMBER then
		text = tonumber(text)
	end
	return text
end

function QUIWidgetLocalConfigInput:getKey()
	return self._configs.key
end

function QUIWidgetLocalConfigInput:getGroup()
	return self._configs.group
end

function QUIWidgetLocalConfigInput:getId()
	return self._configs.id
end

function QUIWidgetLocalConfigInput:getContentSize()
	local tfSize = self._ccbOwner.tf_name:getContentSize()
	local boxSize = self._ccbOwner.sp_box:getContentSize()
	return CCSize(tfSize.width + boxSize.width + 5, boxSize.height)
end

function QUIWidgetLocalConfigInput:updateInputBox()
	self._ccbOwner.tf_value:setVisible(true)
	self._ccbOwner.btn_touch:setVisible(true)
	if self._inputBox then
		self._inputBox:setVisible(false)
	end
end

function QUIWidgetLocalConfigInput:checkInputBox()
	if not self._inputBox then
		self._inputBox = ui.newEditBox({image = "ui/none.png", listener = function()end, size = CCSize(110, 30)})
		self._ccbOwner.node_input:addChild(self._inputBox)
		self._inputBox:setFont(global.font_name, 20)
		self._inputBox:setFontColor(UNITY_COLOR.brown)
		self._inputBox:setPlaceholderFontColor(UNITY_COLOR.brown)
		self._inputBox:setMaxLength(4)
		self._inputBox:setPlaceHolder(self._placeText)
		self._inputBox:registerScriptEditBoxHandler(function(returnType)
			self._ccbOwner.tf_value:setString(self._inputBox:getText())
		end)
	end
	self._inputBox:setPosition(0, 0)
	self._inputBox:setText(self._ccbOwner.tf_value:getString())
end

function QUIWidgetLocalConfigInput:_onTouchBtn()
	self:checkInputBox()
	self._ccbOwner.tf_value:setVisible(false)
	self._ccbOwner.btn_touch:setVisible(false)
	self._inputBox:setVisible(true)
end

return QUIWidgetLocalConfigInput