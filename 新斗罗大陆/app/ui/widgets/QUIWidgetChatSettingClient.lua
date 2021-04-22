-- @Author: xurui
-- @Date:   2019-03-05 15:38:42
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-10-26 19:02:40
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetChatSettingClient = class("QUIWidgetChatSettingClient", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetSwitchBtn = import("..widgets.QUIWidgetSwitchBtn")

QUIWidgetChatSettingClient.EVENT_SWITCH = "EVENT_SWITCH"
local CLOSE_COLOR = ccc3(89, 44, 17)
local OPEN_COLOR = ccc3(255, 255, 255)

function QUIWidgetChatSettingClient:ctor(options)
	local ccbFile = "ccb/Widget_Rongyao_wanjia_client.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
    }
    QUIWidgetChatSettingClient.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._switchStatus = false
end

function QUIWidgetChatSettingClient:setInfo(info, index)
	self._info = info
	self._index = index
	self._switchStatus = self._info.status
	self._ccbOwner.tf_content:setString(self._info.setting or "")
	self._ccbOwner.node_title:setVisible(false)
	self._ccbOwner.node_bg:setVisible(index % 2 == 1)

	self._titleHeight = 0
	if self._info.title then
		self._titleHeight = 60
		self._ccbOwner.tf_title_name:setString(self._info.title)
		self._ccbOwner.node_title:setVisible(true)
	end

	if self._switchBtn == nil then
		self._switchBtn = QUIWidgetSwitchBtn.new()
    	self._ccbOwner.node_btn:addChild(self._switchBtn)
	end
	self._switchBtn:setState(self._switchStatus)
end

function QUIWidgetChatSettingClient:_onTriggerClick()
	self._switchStatus = not self._switchStatus
	self:dispatchEvent({name = QUIWidgetChatSettingClient.EVENT_SWITCH, info = self._info, status = self._switchStatus})
	self._info.status = self._switchStatus
	self:setInfo(self._info, self._index)
end

function QUIWidgetChatSettingClient:getContentSize()
	local size = self._ccbOwner.node_bg_size:getContentSize()
	print(size.width, size.height , self._titleHeight)
	return CCSize(size.width, size.height + self._titleHeight)
end

return QUIWidgetChatSettingClient
