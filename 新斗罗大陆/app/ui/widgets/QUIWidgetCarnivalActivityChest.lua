-- @Author: xurui
-- @Date:   2019-01-22 19:03:24
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-01-23 15:14:32
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetCarnivalActivityChest = class("QUIWidgetCarnivalActivityChest", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")

QUIWidgetCarnivalActivityChest.EVENT_CLICK_CHEST = "EVENT_CLICK_CHEST"

function QUIWidgetCarnivalActivityChest:ctor(options)
	local ccbFile = "ccb/Widget_Carnival_baoxiang.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
    }
    QUIWidgetCarnivalActivityChest.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

end

function QUIWidgetCarnivalActivityChest:onEnter()
end

function QUIWidgetCarnivalActivityChest:onExit()
end

function QUIWidgetCarnivalActivityChest:setInfo(targetInfo)
	self._targetInfo = targetInfo

	self._ccbOwner.node_effect:setVisible(self._targetInfo.completeNum == 2)
	local isDone = self._targetInfo.completeNum == 3
	self._ccbOwner.sp_open:setVisible(isDone)
	self._ccbOwner.sp_close:setVisible(not isDone)

	if isDone then
		self._ccbOwner.tf_count:setVisible(false)
	else
		self._ccbOwner.tf_count:setString((self._targetInfo.haveNum or 0).."/"..(self._targetInfo.value or 0))
	end
end

function QUIWidgetCarnivalActivityChest:_onTriggerClick()
	self:dispatchEvent({name = QUIWidgetCarnivalActivityChest.EVENT_CLICK_CHEST, info = self._targetInfo})
end

function QUIWidgetCarnivalActivityChest:getContentSize()
	return self._ccbOwner.btn_click:getContentSize()
end

return QUIWidgetCarnivalActivityChest
