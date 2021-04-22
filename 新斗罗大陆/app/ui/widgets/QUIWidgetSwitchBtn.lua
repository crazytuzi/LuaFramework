-- @Author: zhouxiaoshu
-- @Date:   2019-10-18 11:03:10
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-11-11 15:50:19
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSwitchBtn = class("QUIWidgetSwitchBtn", QUIWidget)

QUIWidgetSwitchBtn.EVENT_CLICK = "EVENT_CLICK"

local CLOSE_COLOR = ccc3(148, 115, 89)
local OPEN_COLOR = ccc3(255, 255, 255)
local offsetX = 33

function QUIWidgetSwitchBtn:ctor(options)
	local ccbFile = "ccb/Widget_Switch_btn.ccbi"
	if options and options.isBig then
		ccbFile = "ccb/Widget_Switch_btn_big.ccbi"
		offsetX = 45
	end
  	local callBacks = {
  		{ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
  	}
	QUIWidgetSwitchBtn.super.ctor(self,ccbFile,callBacks,options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetSwitchBtn:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetSwitchBtn:setInfo(info)
	self._info = info
	if info.closeFont then
		self._ccbOwner.tf_close:setString(info.closeFont)
	end
	if info.openFont then
		self._ccbOwner.tf_open:setString(info.openFont)
	end
	self:setState(info.isOpen)
end

function QUIWidgetSwitchBtn:setState(state)
	state = state or false
	if state then
		self._ccbOwner.tf_close:setColor(CLOSE_COLOR)
		self._ccbOwner.tf_open:setColor(OPEN_COLOR)
		self._ccbOwner.sp_tab:setPositionX(offsetX)
	else
		self._ccbOwner.tf_close:setColor(OPEN_COLOR)
		self._ccbOwner.tf_open:setColor(CLOSE_COLOR)
		self._ccbOwner.sp_tab:setPositionX(-offsetX)
	end
end

function QUIWidgetSwitchBtn:_onTriggerClick()
    app.sound:playSound("common_switch")
	self:dispatchEvent({name = QUIWidgetSwitchBtn.EVENT_CLICK, info = self._info})
end

return QUIWidgetSwitchBtn