-- @Author: xurui
-- @Date:   2019-01-21 16:39:13
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-01-28 19:14:42
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetCarnivalActivityButton = class("QUIWidgetCarnivalActivityButton", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")

QUIWidgetCarnivalActivityButton.EVENT_CLICK_ACTIVITY_BUTTON = "EVENT_CLICK_ACTIVITY_BUTTON"

function QUIWidgetCarnivalActivityButton:ctor(options)
	local ccbFile = "ccb/Widget_Carnival_Bookmark.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
    }
    QUIWidgetCarnivalActivityButton.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

end

function QUIWidgetCarnivalActivityButton:onEnter()
end

function QUIWidgetCarnivalActivityButton:onExit()
end

function QUIWidgetCarnivalActivityButton:setInfo(info, i)
	self._activityInfo = info
	self._index = i
	
	self._ccbOwner.tf_button_desc:setString(self._activityInfo.title or "")

	local data = string.split(self._activityInfo.params, ",")
	local tip = remote.activityCarnival:checkSubCarnivalActivityTipByIndex(tonumber(data[1]), tonumber(data[2]))
	self._ccbOwner.sp_activity_tips:setVisible(tip)
	self._ccbOwner.node_fca_effect:setVisible(tip)

	if self._activityInfo.title_icon then
		QSetDisplayFrameByPath(self._ccbOwner.sp_activity_bg, self._activityInfo.title_icon)
	end
end

function QUIWidgetCarnivalActivityButton:setSelectStatus(status)
	if status == nil then status = false end

	if self._status ~= status then
		self._status = status
		self._ccbOwner.btn_click:setHighlighted(status)
		self._ccbOwner.btn_click:setEnabled(not status)
	end
end

function QUIWidgetCarnivalActivityButton:_onTriggerClick(event)
	self:dispatchEvent({name = QUIWidgetCarnivalActivityButton.EVENT_CLICK_ACTIVITY_BUTTON, index = self._index})
end

function QUIWidgetCarnivalActivityButton:getContentSize()
	return CCSize(0, 0)
end

return QUIWidgetCarnivalActivityButton
